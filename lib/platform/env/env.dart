export 'env_stub.dart'
    if (dart.library.io) 'env_io.dart'
    if (dart.library.js_interop) 'env_web.dart';
