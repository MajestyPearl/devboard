import 'package:flutter/material.dart';

import '../data/note_repository.dart';
import '../domain/note.dart';
import '../domain/ports/env_info.dart';
import '../domain/ports/quota_port.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({
    super.key,
    required this.repository,
    required this.env,
    required this.quota,
  });

  final NoteRepository repository;
  final EnvInfo env;
  final QuotaPort quota;

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _controller = TextEditingController();

  List<Note> _notes = [];
  QuotaInfo? _quotaInfo;

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final notes = await widget.repository.getAll();
      final quota = await widget.quota.getQuota();

      if (!mounted) return;

      setState(() {
        _notes = notes;
        _quotaInfo = quota;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showMessage('Помилка завантаження: $e');
    }
  }

  Future<void> _addNote() async {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      _showMessage('Введіть текст нотатки');
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await widget.repository.add(text);

      final notes = await widget.repository.getAll();

      if (!mounted) return;

      setState(() {
        _notes = notes;
        _controller.clear();
        _saving = false;
      });

      _showMessage('Нотатку додано');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage('Помилка збереження: $e');
    }
  }

  Future<void> _deleteNote(Note note) async {
    try {
      await widget.repository.remove(note.id);

      final notes = await widget.repository.getAll();

      if (!mounted) return;

      setState(() {
        _notes = notes;
      });

      _showMessage('Нотатку видалено');
    } catch (e) {
      _showMessage('Помилка видалення: $e');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }

    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.dashboard_outlined),
            SizedBox(width: 10),
            Text('DevBoard'),
          ],
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 900,
          ),
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInfoCard(),
                      const SizedBox(height: 16),
                      _buildQuotaCard(),
                      const SizedBox(height: 24),
                      _buildInput(),
                      const SizedBox(height: 24),
                      Expanded(
                        child: _buildNotesList(),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline),
                SizedBox(width: 8),
                Text(
                  'Інформація про платформу',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Платформа: ${widget.env.platformName}'),
            const SizedBox(height: 6),
            Text(
              'Сховище: ${widget.env.storageLocation}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuotaCard() {
    final quota = _quotaInfo;

    if (quota == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(Icons.storage_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Сховище',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Використано: ${_formatBytes(quota.usedBytes)}',
                  ),
                  Text(
                    'Доступно: ${_formatBytes(quota.availableBytes)}',
                  ),
                  Text(
                    'Загальний обсяг: ${_formatBytes(quota.totalBytes)}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            minLines: 1,
            maxLines: 4,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              labelText: 'Нова нотатка',
              hintText: 'Введіть текст...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 56,
          child: FilledButton.icon(
            onPressed: _saving ? null : _addNote,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.add),
            label: const Text('Додати'),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesList() {
    if (_notes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 64,
            ),
            SizedBox(height: 12),
            Text(
              'Поки що немає нотаток',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Створіть першу нотатку вище',
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _notes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final note = _notes[index];

        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 8,
            ),
            leading: CircleAvatar(
              child: Text('${index + 1}'),
            ),
            title: Text(note.text),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Створено: ${_formatDate(note.createdAt)}',
              ),
            ),
            trailing: IconButton(
              tooltip: 'Видалити',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _deleteNote(note),
            ),
          ),
        );
      },
    );
  }
}
