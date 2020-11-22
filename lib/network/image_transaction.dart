import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';

class ImageTransaction {
  static Future<Image> getImage(ip, port) async {
    try {
      var server = await RawServerSocket.bind(InternetAddress.anyIPv4, port,
          shared: true);
      var socket = await server.take(1).first;
      server.close();
      var i = 0;

      List<int> buffer = await socket
          .takeWhile((event) => event != RawSocketEvent.readClosed)
          .fold([], (List<int> buffer, RawSocketEvent e) {
        if (e == RawSocketEvent.read) {
          print("read $i");
          i++;
          var bytes = socket.read();
          if (bytes != null) buffer.addAll(bytes);
        }
        return buffer;
      });
      print("read $i");
      var end_bytes = socket.read();
      if (end_bytes != null) buffer.addAll(end_bytes);
      socket.close();

      return Image.memory(Uint8List.fromList(buffer));
    } on SocketException catch (e) {
      print("problem getting image");
      print(e.toString());
    }
  }
}
