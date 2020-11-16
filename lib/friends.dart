import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'send.dart';
import 'friends_model.dart';

class FriendsTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  TextEditingController ipController;

  void initState() {
    super.initState();
    ipController = TextEditingController();
  }

  void dispose() {
    ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(8), children: [
      RaisedButton(onPressed: _addFriend, child: Text("Add Friend")),
      Text("Friends")
    ]);
  }

  //Widget submitButton = FlatButton(child: Text("Add"), onPressed: () {});

  //Widget cancelButton = FlatButton(child: Text("Cancel"), onPressed: () {});

  _addFriend() async {
    await showDialog<String>(
      context: context,
      child: new AlertDialog(
          contentPadding: const EdgeInsets.all(18.0),
          content: new Row(
            children: <Widget>[
              new Expanded(
                child: new TextField(
                  controller: ipController,
                  decoration: new InputDecoration(
                      labelText: 'Enter your friend\'s ip address',
                      hintText: 'eg. 199.59.102.200'),
                ),
              )
            ],
          ),
          actions: <Widget>[
            new FlatButton(
                child: Text("Add Friend"),
                onPressed: () {
                  Navigator.pop(context);
                }),
            new FlatButton(
                child: Text("Cancel"), onPressed: () => Navigator.pop(context)),
          ]),
    );
  }
}
