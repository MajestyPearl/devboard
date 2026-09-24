import 'package:flutter/material.dart';

import 'data/note_repository.dart';
import 'domain/ports/env_info.dart';
import 'domain/ports/quota_port.dart';
import 'platform/env/env.dart';
import 'platform/quota/quota.dart';
import 'platform/storage/storage.dart';
import 'presentation/notes_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = NoteRepository(
    createNoteStorage(),
  );

  final env = createEnvInfo();

  final quota = createQuotaPort();

  runApp(
    DevBoardApp(
      repository: repository,
      env: env,
      quota: quota,
    ),
  );
}

class DevBoardApp extends StatelessWidget {
  const DevBoardApp({
    super.key,
    required this.repository,
    required this.env,
    required this.quota,
  });

  final NoteRepository repository;
  final EnvInfo env;
  final QuotaPort quota;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevBoard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: NotesPage(
        repository: repository,
        env: env,
        quota: quota,
      ),
    );
  }
}
