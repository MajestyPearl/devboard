import 'dart:io';

import '../../domain/ports/env_info.dart';

EnvInfo createEnvInfo() => IoEnvInfo();

class IoEnvInfo implements EnvInfo {
  @override
  String get platformName =>
      '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';

  @override
  String get storageLocation =>
      'Файл devboard_notes.json у папці документів';
}
