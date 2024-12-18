
import 'dart:typed_data';

bool sizeLimit (Uint8List file) {
  int imageSizeInBytes = file.length;

  const int maxSizeInBytes = 2200000;

  if (imageSizeInBytes < maxSizeInBytes) {
    return true;
  } else {
    return false;
  }
}

