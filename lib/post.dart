import 'package:flutter/material.dart';

import 'package:image_sharing/network/friends_model.dart';

class Post {
  final Image image;
  final Friend sender;

  Post(this.image, this.sender);

  String toString() {
    return image.toString() + " " + sender.toString();
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'image': image,
      'sender': sender,
    };
    return map;
  }
}
