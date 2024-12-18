export 'pick_image.dart'
    if (dart.library.html) 'pick_image_web.dart' //image_picker_webライブラリを使用
    if (dart.library.io) 'pick_image_mobile.dart'; //image_pickerライブラリを使用