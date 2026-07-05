import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<Uint8List?> compressImageToSize(
  File file, {
  int targetSizeInKB = 350,
}) async {
  int quality = 60;
  Uint8List? compressedBytes;
  while (true) {
    compressedBytes = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: quality,
    );
    if (compressedBytes == null) {
      return null;
    }
    final sizeInKB = compressedBytes.length / 1024;
    if (sizeInKB <= targetSizeInKB || quality <= 10) {
      break;
    }
    quality -= 10;
  }
  return compressedBytes;
}
