import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_service.dart';
import '../../data/datasources/notes_local_datasource.dart';
import '../../data/repositories/notes_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../../domain/usecases/notes_usecases.dart';

// Data Source Provider
final notesLocalDataSourceProvider = Provider<NotesLocalDataSource>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return NotesLocalDataSourceImpl(dbService);
});

// Repository Provider
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  final dataSource = ref.watch(notesLocalDataSourceProvider);
  return NotesRepositoryImpl(dataSource);
});

// Use Cases Providers
final getAllNotesUseCaseProvider = Provider<GetAllNotesUseCase>((ref) {
  return GetAllNotesUseCase(ref.watch(notesRepositoryProvider));
});

final getNoteByIdUseCaseProvider = Provider<GetNoteByIdUseCase>((ref) {
  return GetNoteByIdUseCase(ref.watch(notesRepositoryProvider));
});

final createNoteUseCaseProvider = Provider<CreateNoteUseCase>((ref) {
  return CreateNoteUseCase(ref.watch(notesRepositoryProvider));
});

final updateNoteUseCaseProvider = Provider<UpdateNoteUseCase>((ref) {
  return UpdateNoteUseCase(ref.watch(notesRepositoryProvider));
});

final deleteNoteUseCaseProvider = Provider<DeleteNoteUseCase>((ref) {
  return DeleteNoteUseCase(ref.watch(notesRepositoryProvider));
});

final togglePinNoteUseCaseProvider = Provider<TogglePinNoteUseCase>((ref) {
  return TogglePinNoteUseCase(ref.watch(notesRepositoryProvider));
});

final toggleFavoriteNoteUseCaseProvider = Provider<ToggleFavoriteNoteUseCase>((ref) {
  return ToggleFavoriteNoteUseCase(ref.watch(notesRepositoryProvider));
});

// Raw Notes List Provider
final allNotesRawProvider = FutureProvider.autoDispose<List<Note>>((ref) async {
  final useCase = ref.watch(getAllNotesUseCaseProvider);
  return await useCase.execute();
});

// Note Details Provider
final noteDetailProvider = FutureProvider.family.autoDispose<Note?, String>((ref, id) async {
  final useCase = ref.watch(getNoteByIdUseCaseProvider);
  return await useCase.execute(id);
});

// Filter and Sort State
enum NotesTab { all, pinned, favorites }
enum NotesSortOption { pinnedFirst, newestFirst, oldestFirst, alphabetical }

class NotesFilterState {
  final String query;
  final NotesTab activeTab;
  final String? selectedCategory;
  final NotesSortOption sortOption;

  const NotesFilterState({
    this.query = '',
    this.activeTab = NotesTab.all,
    this.selectedCategory,
    this.sortOption = NotesSortOption.pinnedFirst,
  });

  NotesFilterState copyWith({
    String? query,
    NotesTab? activeTab,
    String? selectedCategory,
    bool clearCategory = false,
    NotesSortOption? sortOption,
  }) {
    return NotesFilterState(
      query: query ?? this.query,
      activeTab: activeTab ?? this.activeTab,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

class NotesFilterNotifier extends StateNotifier<NotesFilterState> {
  NotesFilterNotifier() : super(const NotesFilterState());

  void setQuery(String q) {
    state = state.copyWith(query: q);
  }

  void setActiveTab(NotesTab tab) {
    state = state.copyWith(activeTab: tab);
  }

  void setSelectedCategory(String? category) {
    if (category == null || category == 'all') {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  void setSortOption(NotesSortOption option) {
    state = state.copyWith(sortOption: option);
  }

  void resetFilters() {
    state = const NotesFilterState();
  }
}

final notesFilterProvider = StateNotifierProvider<NotesFilterNotifier, NotesFilterState>((ref) {
  return NotesFilterNotifier();
});

// Computed Filtered & Sorted Notes Provider
final filteredNotesProvider = Provider.autoDispose<AsyncValue<List<Note>>>((ref) {
  final allNotesAsync = ref.watch(allNotesRawProvider);
  final filter = ref.watch(notesFilterProvider);

  return allNotesAsync.whenData((notes) {
    final query = filter.query.trim().toLowerCase();

    // 1. Filter by Tab
    var list = notes.where((note) {
      if (filter.activeTab == NotesTab.pinned && !note.isPinned) return false;
      if (filter.activeTab == NotesTab.favorites && !note.isFavorite) return false;
      return true;
    }).toList();

    // 2. Filter by Category
    if (filter.selectedCategory != null && filter.selectedCategory!.isNotEmpty) {
      list = list.where((note) => note.category == filter.selectedCategory).toList();
    }

    // 3. Filter by Search Query
    if (query.isNotEmpty) {
      list = list.where((note) {
        final matchTitle = note.title.toLowerCase().contains(query);
        final matchContent = note.content.toLowerCase().contains(query);
        final matchCategory = note.category.toLowerCase().contains(query);
        final matchTags = note.tags.any((t) => t.toLowerCase().contains(query));
        final matchRecipe = (note.relatedRecipeTitle ?? '').toLowerCase().contains(query);
        return matchTitle || matchContent || matchCategory || matchTags || matchRecipe;
      }).toList();
    }

    // 4. Sort Notes
    switch (filter.sortOption) {
      case NotesSortOption.pinnedFirst:
        list.sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          return b.updatedAt.compareTo(a.updatedAt);
        });
        break;
      case NotesSortOption.newestFirst:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case NotesSortOption.oldestFirst:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case NotesSortOption.alphabetical:
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }

    return list;
  });
});

// Actions Controller
class NotesController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  NotesController(this.ref) : super(const AsyncValue.data(null));

  Future<void> createNote(Note note) async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.read(createNoteUseCaseProvider);
      await useCase.execute(note);
      state = const AsyncValue.data(null);
      ref.invalidate(allNotesRawProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateNote(Note note) async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.read(updateNoteUseCaseProvider);
      await useCase.execute(note);
      state = const AsyncValue.data(null);
      ref.invalidate(allNotesRawProvider);
      ref.invalidate(noteDetailProvider(note.id));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteNote(String id) async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.read(deleteNoteUseCaseProvider);
      await useCase.execute(id);
      state = const AsyncValue.data(null);
      ref.invalidate(allNotesRawProvider);
      ref.invalidate(noteDetailProvider(id));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> togglePin(String id) async {
    try {
      final useCase = ref.read(togglePinNoteUseCaseProvider);
      await useCase.execute(id);
      ref.invalidate(allNotesRawProvider);
      ref.invalidate(noteDetailProvider(id));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      final useCase = ref.read(toggleFavoriteNoteUseCaseProvider);
      await useCase.execute(id);
      ref.invalidate(allNotesRawProvider);
      ref.invalidate(noteDetailProvider(id));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final notesControllerProvider = StateNotifierProvider<NotesController, AsyncValue<void>>((ref) {
  return NotesController(ref);
});
