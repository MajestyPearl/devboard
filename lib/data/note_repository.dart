import '../domain/note.dart';
import '../domain/ports/note_storage.dart';

class NoteRepository {
  NoteRepository(this._storage);

  final NoteStorage _storage;

  List<Note>? _cache;

  Future<List<Note>> getAll() async {
    return _cache ??= await _storage.readAll();
  }

  Future<void> add(String text) async {
    final cleanText = text.trim();

    if (cleanText.isEmpty) {
      throw ArgumentError('Порожня нотатка не зберігається');
    }

    final notes = await getAll();

    final now = DateTime.now();

    final note = Note(
      id: now.microsecondsSinceEpoch.toString(),
      text: cleanText,
      createdAt: now,
    );

    _cache = [...notes, note];

    await _storage.writeAll(_cache!);
  }

  Future<void> remove(String id) async {
    final notes = await getAll();

    _cache = notes.where((note) => note.id != id).toList();

    await _storage.writeAll(_cache!);
  }
}
