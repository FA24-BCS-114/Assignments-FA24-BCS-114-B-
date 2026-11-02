import 'dart:io';
import 'dart:typed_data';

Future<Uint8List?> readLocalFileBytes114(String path) async {
  final file = File(path);
  if (!await file.exists()) return null;
  return Uint8List.fromList(await file.readAsBytes());
}
