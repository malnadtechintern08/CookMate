import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class GetAllNotesUseCase {
  final NotesRepository repository;
  const GetAllNotesUseCase(this.repository);

  Future<List<Note>> execute() async {
    return await repository.getAllNotes();
  }
}

class GetNoteByIdUseCase {
  final NotesRepository repository;
  const GetNoteByIdUseCase(this.repository);

  Future<Note?> execute(String id) async {
    return await repository.getNoteById(id);
  }
}

class CreateNoteUseCase {
  final NotesRepository repository;
  const CreateNoteUseCase(this.repository);

  Future<void> execute(Note note) async {
    await repository.createNote(note);
  }
}

class UpdateNoteUseCase {
  final NotesRepository repository;
  const UpdateNoteUseCase(this.repository);

  Future<void> execute(Note note) async {
    await repository.updateNote(note);
  }
}

class DeleteNoteUseCase {
  final NotesRepository repository;
  const DeleteNoteUseCase(this.repository);

  Future<void> execute(String id) async {
    await repository.deleteNote(id);
  }
}

class TogglePinNoteUseCase {
  final NotesRepository repository;
  const TogglePinNoteUseCase(this.repository);

  Future<void> execute(String id) async {
    await repository.togglePin(id);
  }
}

class ToggleFavoriteNoteUseCase {
  final NotesRepository repository;
  const ToggleFavoriteNoteUseCase(this.repository);

  Future<void> execute(String id) async {
    await repository.toggleFavorite(id);
  }
}
