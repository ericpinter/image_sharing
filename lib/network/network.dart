import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_sharing/network/image_transaction.dart';
import '../post.dart';
import 'friends_model.dart';
import 'network_utils.dart';

//Modeled off of Dr Ferrer's socket text chat example
//https://github.com/gjf2a/text_messenger/blob/master/lib/data.dart
class NetworkLog {
  Friends friends = new Friends();
  bool persist;
  var _message_callback;
  List<Post> _feed = [];

  get feed => _feed;

  NetworkLog(this._message_callback, {this.persist = true});

  static Future<NetworkLog> getLog(message_callback, {persist = true}) async {
    NetworkLog log = new NetworkLog(message_callback, persist: persist);

    await log._setupServer(negotiationPort);
    await log.getFeed();
    return log;
  }

  Future<void> _setupServer(port) async {
    try {
      ServerSocket server =
          await ServerSocket.bind(InternetAddress.anyIPv4, port, shared: true);
      server.listen(_listenAsNegotiator);
    } on SocketException catch (e) {
      print("problem in negotiation");
      print(e.toString());
    }
  }

  Future<void> getFeed() async {
    //TODO replace with new code
    /*
    var query = await DatabaseHelper.instance.queryAllRows();
    _feed = query
        .map((json) => Cat.fromJson(json))
        .where((cat) => cat != null)
        .toList();
    */
  }

  Future<void> _updateDatabase() async {
    //TODO replace with new code
    //await DatabaseHelper.instance.insert(cat);
    //await getDropDownCatValue();
  }

  //facilitates a transfer on a specified other socket (the port is whatever the data given is)
  void _listenAsNegotiator(Socket socket) {
    socket.listen((data) async {
      var s = String.fromCharCodes(data);
      TransferRequest request = TransferRequest.fromJson(jsonDecode(s));
      friends.add(request.sender);
      print("setting up other port");
      var img = await ImageTransaction.getImage(
          socket.remoteAddress.address, request.port);
      if (img != null) {
        feed.add(Post(img, request.sender));
        print("finishing image reception");
        _message_callback();
        _updateDatabase();
      } else {
        print("Problem in getting image");
      }
    });
  }

  //TODO refactor this to work with groups as well
  Future<void> sendImage(Set<Friend> fset, PickedFile img) async {
    var widget = PickedFileToWidget(img);
    feed.add(Post(widget, Friend("127.0.0.1", name: "self")));
    for (Friend f in fset) {
      friends.add(f);
      friends.sendImage(f.ip, img);
    }
  }
}
