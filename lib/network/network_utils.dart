import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'dart:ui' as UI;
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart' as Widget;
import 'package:image_picker/image_picker.dart';
import 'package:json_annotation/json_annotation.dart';
import 'friends_model.dart';

part 'network_utils.g.dart';

const int negotiationPort = 4444;

@JsonSerializable(nullable: false)
class TransferRequest {
  final Friend sender;
  final int port;

  TransferRequest({this.sender, this.port});

  String toString() {
    return jsonEncode(this);
  }

  factory TransferRequest.fromJson(Map<String, dynamic> json) =>
      _$TransferRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TransferRequestToJson(this);
}

class SocketOutcome {
  String _errorMessage;

  SocketOutcome({String errorMsg = ""}) {
    _errorMessage = errorMsg;
  }

  bool get sent => _errorMessage.length == 0;

  String get errorMessage => _errorMessage;

  String toString() {
    return "successful $sent. error [$errorMessage]";
  }
}

Widget.Image PickedFileToWidget(PickedFile img) {
  return Widget.Image.file(File(img.path));
}
