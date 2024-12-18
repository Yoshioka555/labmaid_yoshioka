export 'save_image.dart'
if (dart.library.html) 'save_image_web.dart' //image_downloader_webライブラリを使用
if (dart.library.io) 'save_image_mobile.dart'; //image_gallery_saverライブラリを使用

