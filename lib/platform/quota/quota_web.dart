import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../../domain/ports/quota_port.dart';

QuotaPort createQuotaPort() => WebQuotaPort();

class WebQuotaPort implements QuotaPort {
  @override
  Future<QuotaInfo> getQuota() async {
    final estimate =
        await web.window.navigator.storage.estimate().toDart;

    final usage = estimate.usage;
    final quota = estimate.quota;

    return QuotaInfo(
      usedBytes: usage.toInt(),
      totalBytes: quota.toInt(),
    );
  }
}
