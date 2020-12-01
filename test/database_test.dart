import 'dart:async';
import 'package:flutter/widgets.dart' as Widget;
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_sharing/database/friends_database.dart';
import 'package:image_sharing/database/posts_database.dart';
import 'package:image_sharing/network/friends_model.dart';
import 'package:image_sharing/network/network.dart';
import 'package:image_sharing/network/network_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Store friend', (WidgetTester wt) async {
    await FriendDatabase.init();
    var self = Friend("127.0.0.1");
    FriendDatabase.insertFriend(self);
    var friends = await FriendDatabase.friends();
    print(friends);
    expect(true, friends.length > 0);//can't test that it's exactly 0 because the device could already have friends put in

  });
}
