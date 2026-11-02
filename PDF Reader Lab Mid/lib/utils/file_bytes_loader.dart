export 'file_bytes_loader_io.dart'
    if (dart.library.js_interop) 'file_bytes_loader_web.dart'
    if (dart.library.html) 'file_bytes_loader_web.dart';
