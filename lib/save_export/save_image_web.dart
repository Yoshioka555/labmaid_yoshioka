import 'package:image_downloader_web/image_downloader_web.dart';
import 'dart:typed_data';

class SaveImage {
  Future<void> saveImage(Uint8List image) async {
    await WebImageDownloader.downloadImageFromUInt8List(
        uInt8List: image,
    );
  }
}