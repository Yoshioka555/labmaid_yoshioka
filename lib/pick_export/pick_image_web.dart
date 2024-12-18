import 'package:image_picker_web/image_picker_web.dart';
import 'dart:typed_data';

class PickImage {
  Future<Uint8List?> pickImage() async {
    Uint8List? bytesFromPicker = await ImagePickerWeb.getImageAsBytes();
    if (bytesFromPicker == null) return null;
    return bytesFromPicker;
  }
}