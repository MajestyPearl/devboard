import 'dart:convert';
import 'dart:io';

import '../../domain/ports/quota_port.dart';

QuotaPort createQuotaPort() => IoQuotaPort();

class IoQuotaPort implements QuotaPort {
  @override
  Future<QuotaInfo> getQuota() async {
    final result = await Process.run(
      'powershell.exe',
      [
        '-NoProfile',
        '-Command',
        r'''
$disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
[PSCustomObject]@{
  FreeSpace = [int64]$disk.FreeSpace
  Size = [int64]$disk.Size
} | ConvertTo-Json -Compress
''',
      ],
    );

    if (result.exitCode != 0) {
      throw Exception(
        'Не вдалося отримати інформацію про диск C:',
      );
    }

    final data =
        jsonDecode(result.stdout.toString()) as Map<String, dynamic>;

    final freeBytes = (data['FreeSpace'] as num).toInt();
    final totalBytes = (data['Size'] as num).toInt();

    return QuotaInfo(
      usedBytes: totalBytes - freeBytes,
      totalBytes: totalBytes,
    );
  }
}
