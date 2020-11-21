import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'send.dart';
import 'network/friends_model.dart';

class FriendsTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  TextEditingController ipController;
  TextEditingController nameController;
  Friends friends = Friends();

  void initState() {
    super.initState();
    ipController = TextEditingController();
    nameController = TextEditingController();
  }

  void dispose() {
    //TODO: Probably impolite to not dispose of these, but they got dumped
    // whenever the form closed before, which was hard to work with

    //ipController.dispose();
    //nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        padding: const EdgeInsets.all(8), children: _renderFriends());
  }

  //Widget submitButton = FlatButton(child: Text("Add"), onPressed: () {});

  //Widget cancelButton = FlatButton(child: Text("Cancel"), onPressed: () {});

  List<Widget> _renderFriends() {
    List<Widget> friendBlocks = new List<Widget>();
    friendBlocks.add(
        RaisedButton(onPressed: _addFriendPrompt, child: Text("Add Friend")));
    for (Friend f in friends) {
      Container friendBlock = new Container(
        height: 50,
        child: Center(child: Text(f.name)),
      );

      friendBlocks.add(friendBlock);
    }
    return friendBlocks;
  }

  _addFriendPrompt() async {
    final _formKey = GlobalKey<FormState>();
    await showDialog<String>(
      context: context,
      child: new AlertDialog(
          contentPadding: const EdgeInsets.all(18.0),
          content: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _ipField(),
                    _nameField(),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            new FlatButton(
                child: Text("Add Friend"),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    setState(() {
                      _addFriend(ipController.text, nameController.text);
                    });
                    Navigator.pop(context);
                  }
                }),
            new FlatButton(
                child: Text("Cancel"), onPressed: () => Navigator.pop(context)),
          ]),
    );
  }

  Widget _ipField() {
    return TextFormField(
      controller: ipController,
      keyboardType: TextInputType.number,
      validator: _ipValidate,
      decoration: InputDecoration(labelText: "IP Address"),
    );
  }

  Widget _nameField() {
    return TextFormField(
      controller: nameController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(labelText: "Name"),
    );
  }

  void _addFriend(String ipAddr, String name) {
    friends.add(new Friend(ipAddr, name: name));
  }

  String _ipValidate(String value) {
    if (value.isEmpty) {
      return 'Please enter an IP address';
    } else {
      List<String> splitList = value.split('.');
      if (splitList.length != 4) return "Invalid IP Address";
      for (String substring in splitList) {
        if (!_isNumeric(substring)) return "Invalid IP Address";
        int num = int.parse(substring);
        if (num < 0 || num > 255) return "Invalid IP Address";
      }
    }
    return null;
  }

  bool _isNumeric(String str) {
    return double.tryParse(str) != null;
  }
}
