import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as UI;
import 'package:flutter/widgets.dart' as Widgets;

//https://stackoverflow.com/questions/46145472/how-to-convert-base64-string-into-image-with-flutter
Widgets.Image imageFromBase64String(String base64String) {
  return Widgets.Image.memory(base64Decode(base64String));
}

Future<UI.Image> bytesToUI(Uint8List bytes) async {

  return (await WidgetoUIImage(Widgets.Image.memory(bytes))).image;
}


Future<Uint8List> toBytes(UI.Image img) async {
  return Uint8List.view((await img.toByteData()).buffer);
}

Future<Widgets.ImageInfo> WidgetoUIImage(Widgets.Image img) async {
  Completer completer = Completer<Widgets.ImageInfo>();

  final Widgets.ImageStreamListener listener = Widgets.ImageStreamListener(
          (Widgets.ImageInfo imageInfo, bool synchronousCall) {
        // Trigger a build whenever the image changes.
        completer.complete(imageInfo);
      });

  img.image.resolve(Widgets.ImageConfiguration.empty).addListener(listener);
  return completer.future;
}

Future<Widgets.Image> UIImageToWidget(UI.Image img) async {
  var bytes = await toBytes(img);
  return Widgets.Image.memory(bytes);
}




Uint8List dataFromBase64String(String base64String) {
  return base64Decode(base64String);
}

String base64String(Uint8List data) {
  return base64Encode(data);
}
