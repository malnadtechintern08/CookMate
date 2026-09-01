import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/note_model.dart';

abstract class NotesLocalDataSource {
  Future<List<NoteModel>> getAllNotes();
  Future<NoteModel?> getNoteById(String id);
  Future<void> createNote(NoteModel note);
  Future<void> updateNote(NoteModel note);
  Future<void> deleteNote(String id);
  Future<void> togglePin(String id);
  Future<void> toggleFavorite(String id);
}

class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  final DatabaseService databaseService;

  NotesLocalDataSourceImpl(this.databaseService);

  @override
  Future<List<NoteModel>> getAllNotes() async {
    try {
      final db = await databaseService.database;
      final results = await db.query(
        'notes',
        orderBy: 'is_pinned DESC, updated_at DESC',
      );
      return results.map((row) => NoteModel.fromMap(row)).toList();
    } catch (e) {
      throw AppDatabaseException('Failed to fetch notes: $e');
    }
  }

  @override
  Future<NoteModel?> getNoteById(String id) async {
    try {
      final db = await databaseService.database;
      final results = await db.query(
        'notes',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (results.isEmpty) return null;
      return NoteModel.fromMap(results.first);
    } catch (e) {
      throw AppDatabaseException('Failed to fetch note by id ($id): $e');
    }
  }

  @override
  Future<void> createNote(NoteModel note) async {
    try {
      final db = await databaseService.database;
      await db.insert(
        'notes',
        note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw AppDatabaseException('Failed to insert note: $e');
    }
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    try {
      final db = await databaseService.database;
      await db.update(
        'notes',
        note.toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );
    } catch (e) {
      throw AppDatabaseException('Failed to update note: $e');
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      final db = await databaseService.database;
      await db.delete(
        'notes',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppDatabaseException('Failed to delete note ($id): $e');
    }
  }

  @override
  Future<void> togglePin(String id) async {
    try {
      final db = await databaseService.database;
      await db.rawUpdate('''
        UPDATE notes
        SET is_pinned = CASE WHEN is_pinned = 1 THEN 0 ELSE 1 END,
            updated_at = ?
        WHERE id = ?
      ''', [DateTime.now().toIso8601String(), id]);
    } catch (e) {
      throw AppDatabaseException('Failed to toggle pin for note ($id): $e');
    }
  }

  @override
  Future<void> toggleFavorite(String id) async {
    try {
      final db = await databaseService.database;
      await db.rawUpdate('''
        UPDATE notes
        SET is_favorite = CASE WHEN is_favorite = 1 THEN 0 ELSE 1 END,
            updated_at = ?
        WHERE id = ?
      ''', [DateTime.now().toIso8601String(), id]);
    } catch (e) {
      throw AppDatabaseException('Failed to toggle favorite for note ($id): $e');
    }
  }
}
