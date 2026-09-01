import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cookmate/features/notes/data/datasources/notes_local_datasource.dart';
import 'package:cookmate/features/notes/data/models/note_model.dart';
import 'package:cookmate/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:cookmate/features/notes/domain/entities/note.dart';
import 'package:cookmate/features/notes/presentation/providers/notes_providers.dart';
import 'package:cookmate/features/notes/presentation/screens/notes_screen.dart';
import 'package:cookmate/features/notes/presentation/widgets/note_card.dart';
import 'package:cookmate/l10n/app_localizations.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Note Entity and NoteModel Tests', () {
    test('Note entity copyWith and helpers work correctly', () {
      final now = DateTime.now();
      final note = Note(
        id: 'note-1',
        title: 'Sunday Breakfast Ideas',
        content: 'Try neer dosa with coconut chutney and filter coffee.',
        category: NoteCategory.mealPlan,
        tags: const ['Breakfast', 'South Indian'],
        isPinned: true,
        isFavorite: true,
        relatedRecipeId: 'rec-10',
        relatedRecipeTitle: 'Neer Dosa',
        createdAt: now,
        updatedAt: now,
      );

      expect(note.hasRelatedRecipe, isTrue);
      expect(note.snippet, contains('Try neer dosa'));

      final updated = note.copyWith(
        title: 'Sunday Brunch',
        isPinned: false,
        clearRelatedRecipe: true,
      );

      expect(updated.title, equals('Sunday Brunch'));
      expect(updated.isPinned, isFalse);
      expect(updated.hasRelatedRecipe, isFalse);
      expect(updated.relatedRecipeId, isNull);
    });

    test('NoteModel serialization and deserialization roundtrip', () {
      final now = DateTime.parse('2026-09-01T10:00:00.000Z');
      final model = NoteModel(
        id: 'note-101',
        title: 'Spice Mix Ratio',
        content: '2 parts coriander, 1 part cumin, 0.5 part black pepper.',
        category: NoteCategory.kitchenTip,
        tags: const ['Spices', 'Rasam'],
        isPinned: true,
        isFavorite: false,
        relatedRecipeId: 'rec-15',
        relatedRecipeTitle: 'Malnad Pepper Rasam',
        createdAt: now,
        updatedAt: now,
      );

      final map = model.toMap();
      expect(map['id'], equals('note-101'));
      expect(map['is_pinned'], equals(1));
      expect(map['is_favorite'], equals(0));

      final deserialized = NoteModel.fromMap(map);
      expect(deserialized.id, equals(model.id));
      expect(deserialized.title, equals(model.title));
      expect(deserialized.tags, equals(model.tags));
      expect(deserialized.isPinned, isTrue);
      expect(deserialized.isFavorite, isFalse);
      expect(deserialized.relatedRecipeId, equals('rec-15'));
    });
  });

  group('Notes Repository and SQLite Data Source Tests', () {
    late Database db;
    late NotesLocalDataSource dataSource;
    late NotesRepositoryImpl repository;

    setUp(() async {
      db = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE notes (
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              content TEXT NOT NULL,
              category TEXT NOT NULL,
              tags TEXT NOT NULL,
              is_pinned INTEGER NOT NULL DEFAULT 0,
              is_favorite INTEGER NOT NULL DEFAULT 0,
              related_recipe_id TEXT,
              related_recipe_title TEXT,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');
        },
      );

      // Inject db mock into dataSource
      dataSource = _TestNotesLocalDataSource(db);
      repository = NotesRepositoryImpl(dataSource);
    });

    tearDown(() async {
      await db.close();
    });

    test('CRUD operations and pin/favorite toggles work properly', () async {
      final now = DateTime.now();
      final note1 = Note(
        id: 'n1',
        title: 'Akki Rotti Secret',
        content: 'Add grated dill leaves and finely chopped onions to the dough.',
        category: NoteCategory.malnadRecipe,
        tags: const ['Malnad', 'Breakfast'],
        isPinned: false,
        isFavorite: false,
        createdAt: now,
        updatedAt: now,
      );

      // 1. Create
      await repository.createNote(note1);
      var notes = await repository.getAllNotes();
      expect(notes.length, equals(1));
      expect(notes.first.title, equals('Akki Rotti Secret'));

      // 2. Toggle Pin
      await repository.togglePin('n1');
      var fetched = await repository.getNoteById('n1');
      expect(fetched?.isPinned, isTrue);

      // 3. Toggle Favorite
      await repository.toggleFavorite('n1');
      fetched = await repository.getNoteById('n1');
      expect(fetched?.isFavorite, isTrue);

      // 4. Update
      final updatedNote = fetched!.copyWith(title: 'Akki Rotti Pro Secret');
      await repository.updateNote(updatedNote);
      fetched = await repository.getNoteById('n1');
      expect(fetched?.title, equals('Akki Rotti Pro Secret'));

      // 5. Delete
      await repository.deleteNote('n1');
      notes = await repository.getAllNotes();
      expect(notes.isEmpty, isTrue);
    });
  });

  group('Notes Filter and Sort Provider Tests', () {
    test('FilterNotifier updates queries and tabs', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(notesFilterProvider.notifier);
      expect(container.read(notesFilterProvider).query, isEmpty);
      expect(container.read(notesFilterProvider).activeTab, equals(NotesTab.all));

      notifier.setQuery('Dosa');
      expect(container.read(notesFilterProvider).query, equals('Dosa'));

      notifier.setActiveTab(NotesTab.pinned);
      expect(container.read(notesFilterProvider).activeTab, equals(NotesTab.pinned));

      notifier.setSelectedCategory(NoteCategory.mealPlan);
      expect(container.read(notesFilterProvider).selectedCategory, equals(NoteCategory.mealPlan));

      notifier.setSortOption(NotesSortOption.alphabetical);
      expect(container.read(notesFilterProvider).sortOption, equals(NotesSortOption.alphabetical));

      notifier.resetFilters();
      expect(container.read(notesFilterProvider).query, isEmpty);
      expect(container.read(notesFilterProvider).activeTab, equals(NotesTab.all));
    });
  });

  group('Notes Widget UI Tests', () {
    testWidgets('NoteCard renders title, snippet, pin icon and triggers taps', (WidgetTester tester) async {
      bool tapped = false;
      final note = Note(
        id: 'w1',
        title: 'Filter Coffee Ratio',
        content: '80% Plantation A coffee and 20% chicory boiled to perfection.',
        category: NoteCategory.kitchenTip,
        tags: const ['Coffee', 'Morning'],
        isPinned: true,
        isFavorite: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: NoteCard(
              note: note,
              onTap: () => tapped = true,
              onEdit: () {},
              onDelete: () {},
              onTogglePin: () {},
              onToggleFavorite: () {},
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Filter Coffee Ratio'), findsOneWidget);
      expect(find.text('#Coffee'), findsOneWidget);
      expect(find.byIcon(Icons.push_pin_rounded), findsWidgets);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

      await tester.tap(find.text('Filter Coffee Ratio'));
      expect(tapped, isTrue);
    });

    testWidgets('NotesScreen renders empty state when no notes exist', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allNotesRawProvider.overrideWith((ref) => Future.value([])),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: NotesScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('📝 My Notes'), findsOneWidget);
      expect(find.text('No notes yet'), findsOneWidget);
      expect(find.text('Create First Note'), findsOneWidget);
      expect(find.text('Add Note'), findsOneWidget);
    });
  });
}

class _TestNotesLocalDataSource implements NotesLocalDataSource {
  final Database db;
  _TestNotesLocalDataSource(this.db);

  @override
  Future<List<NoteModel>> getAllNotes() async {
    final res = await db.query('notes', orderBy: 'is_pinned DESC, updated_at DESC');
    return res.map((r) => NoteModel.fromMap(r)).toList();
  }

  @override
  Future<NoteModel?> getNoteById(String id) async {
    final res = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    if (res.isEmpty) return null;
    return NoteModel.fromMap(res.first);
  }

  @override
  Future<void> createNote(NoteModel note) async {
    await db.insert('notes', note.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    await db.update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  @override
  Future<void> deleteNote(String id) async {
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> togglePin(String id) async {
    await db.rawUpdate('''
      UPDATE notes
      SET is_pinned = CASE WHEN is_pinned = 1 THEN 0 ELSE 1 END,
          updated_at = ?
      WHERE id = ?
    ''', [DateTime.now().toIso8601String(), id]);
  }

  @override
  Future<void> toggleFavorite(String id) async {
    await db.rawUpdate('''
      UPDATE notes
      SET is_favorite = CASE WHEN is_favorite = 1 THEN 0 ELSE 1 END,
          updated_at = ?
      WHERE id = ?
    ''', [DateTime.now().toIso8601String(), id]);
  }
}
