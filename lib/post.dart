import 'dart:ui';
import 'package:image_sharing/database/image_utils.dart';
import 'package:image_sharing/network/friends_model.dart';

class Post {
  final Image image;
  final Friend sender;

  Post(this.image, this.sender);

  String toString() {
    return image.toString() + " " + sender.toString();
  }

  Future<Map<String, dynamic>> toMap() async {
    var map = <String, dynamic>{
      'image': await toBytes(image),
      'sender': sender.ip,
    };
    return map;
  }
}
