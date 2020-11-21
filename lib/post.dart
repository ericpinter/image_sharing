import 'package:flutter/material.dart';

import 'package:image_sharing/network/friends_model.dart';

class Post {
  final Image image;
  final Friend sender;

  Post(this.image, this.sender);
}
