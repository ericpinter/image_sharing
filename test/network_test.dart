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

  test('Transfer image', () async {
    Friends.init(persist: false);
    var self = Friend("127.0.0.1");
    var friends = Friends();
    friends.add(self);
    var image_received = Completer();
    var log = await NetworkLog.getLog(() {
      image_received.complete();
    }, persist: false);

    var picked = PickedFile("../images/test.png");

    expect(log.feed.length, 0);
    await friends.sendImage(self.ip, picked);
    print(log.feed);
    print(log.friends);
    expect(log.friends.length, 1);
    await image_received.future;
    print(log.feed);
    expect(log.feed.length, 1);
    expect(log.feed[0], isNotNull);
    print(log.feed[0].image.height);
    expect(
        log.feed[0].image.height,
        500); //actually testing the images being the same is hard, but this is close
  });
}
