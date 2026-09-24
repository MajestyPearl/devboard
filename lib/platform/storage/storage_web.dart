import 'dart:convert';

import 'package:web/web.dart' as web;

import '../../domain/note.dart';
import '../../domain/ports/note_storage.dart';

NoteStorage createNoteStorage() => LocalStorageNoteStorage();

const _key = 'devboard_notes';

class LocalStorageNoteStorage implements NoteStorage {
  @override
  Future<List<Note>> readAll() async {
    final raw = web.window.localStorage.getItem(_key);

    if (raw == null || raw.trim().isEmpty) {
      return [];
    }

    final list = jsonDecode(raw) as List<dynamic>;

    return list
        .map((e) => Note.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> writeAll(List<Note> notes) async {
    web.window.localStorage.setItem(
      _key,
      jsonEncode(notes.map((n) => n.toJson()).toList()),
    );
  }
}
