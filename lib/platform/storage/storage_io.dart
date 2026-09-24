import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../domain/note.dart';
import '../../domain/ports/note_storage.dart';

NoteStorage createNoteStorage() => FileNoteStorage();

class FileNoteStorage implements NoteStorage {
  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();

    return File('${dir.path}/devboard_notes.json');
  }

  @override
  Future<List<Note>> readAll() async {
    final f = await _file();

    if (!await f.exists()) {
      return [];
    }

    final raw = await f.readAsString();

    if (raw.trim().isEmpty) {
      return [];
    }

    final list = jsonDecode(raw) as List<dynamic>;

    return list
        .map((e) => Note.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> writeAll(List<Note> notes) async {
    final f = await _file();

    await f.writeAsString(
      jsonEncode(notes.map((n) => n.toJson()).toList()),
    );
  }
}
