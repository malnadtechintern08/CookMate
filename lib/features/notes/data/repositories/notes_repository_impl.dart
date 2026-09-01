import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_local_datasource.dart';
import '../models/note_model.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDataSource localDataSource;

  NotesRepositoryImpl(this.localDataSource);

  @override
  Future<List<Note>> getAllNotes() async {
    final models = await localDataSource.getAllNotes();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Note?> getNoteById(String id) async {
    final model = await localDataSource.getNoteById(id);
    return model?.toEntity();
  }

  @override
  Future<void> createNote(Note note) async {
    final model = NoteModel.fromEntity(note);
    await localDataSource.createNote(model);
  }

  @override
  Future<void> updateNote(Note note) async {
    final model = NoteModel.fromEntity(note);
    await localDataSource.updateNote(model);
  }

  @override
  Future<void> deleteNote(String id) async {
    await localDataSource.deleteNote(id);
  }

  @override
  Future<void> togglePin(String id) async {
    await localDataSource.togglePin(id);
  }

  @override
  Future<void> toggleFavorite(String id) async {
    await localDataSource.toggleFavorite(id);
  }
}
