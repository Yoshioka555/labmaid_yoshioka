
import 'dart:typed_data';

import 'package:saver_gallery/saver_gallery.dart';

class SaveImage {
  Future<void> saveImage(Uint8List image) async {
    final result = await SaverGallery.saveImage(
      image,
      quality: 100,
      fileName: 'chat_image_data',
      androidRelativePath: "Pictures/appName/images",
      skipIfExists: false,
    );
    print(result.toString());
  }
}



