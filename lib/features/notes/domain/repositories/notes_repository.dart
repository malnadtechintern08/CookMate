import '../entities/note.dart';

abstract class NotesRepository {
  Future<List<Note>> getAllNotes();
  Future<Note?> getNoteById(String id);
  Future<void> createNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String id);
  Future<void> togglePin(String id);
  Future<void> toggleFavorite(String id);
}
