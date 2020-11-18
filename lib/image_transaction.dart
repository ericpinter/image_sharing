import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';

class ImageTransaction {
  static Future<Image> getImage(port) async {
    try {
      var server = await RawServerSocket.bind(InternetAddress.anyIPv4, port);
      var socket = await server.take(1).first;
      server.close();
      List<int> buffer = await socket
          .takeWhile((event) => event != RawSocketEvent.readClosed)
          .fold([], (List<int> buffer, _) {
            var bytes = socket.read();
            if (bytes != null) buffer.addAll(bytes);
            return buffer;
      });
      var bytes = socket.read();
      if (bytes != null) buffer.addAll(bytes);

      return Image.memory(Uint8List.fromList(buffer));
    } on SocketException catch (e) {
      print(e.toString());
    }
  }
}
