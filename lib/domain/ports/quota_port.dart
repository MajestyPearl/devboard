abstract interface class QuotaPort {
  Future<QuotaInfo> getQuota();
}

class QuotaInfo {
  const QuotaInfo({
    required this.usedBytes,
    required this.totalBytes,
  });

  final int usedBytes;
  final int totalBytes;

  int get availableBytes {
    final result = totalBytes - usedBytes;
    return result < 0 ? 0 : result;
  }
}
