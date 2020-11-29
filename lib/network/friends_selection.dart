import 'package:flutter/material.dart';
import 'package:image_sharing/network/friends_model.dart';

class FriendsSelection {
  Friends _friends;
  List<bool> _isSelected;
  var reload;

  get friends => _friends;

  Set<Friend> selected() {
    List<Friend> _friendsList = _friends.asList;
    return {
      for (int i = 0; i < _friendsList.length; i++)
        if (_isSelected[i]) _friendsList[i]
    };
  }

  FriendsSelection(this._friends, this.reload) {
    _isSelected = [for (int i = 0; i < _friends.length; i++) false];
  }

  add(Friend f) {
    var old_length = friends.length;
    _friends.add(f);
    if (friends.length > old_length) _isSelected.add(false);
    reload();
  }

  newGroup(List<Friend> flist) {
    _friends.groups.add(flist);
    reload();
  }

  List<Widget> asWidgetList() {
    List<Friend> _friendsList = _friends.asList;
    print(_friendsList);
    print(_isSelected);

    return [
      for (int i = 0; i < _friends.length; i++)
        CheckboxListTile(
            title: Text(_friendsList[i].name),
            subtitle: Text(_friendsList[i].describe()),
            secondary: Icon(Icons.person),
            value: _isSelected[i],
            onChanged: (bool newValue) {
              _isSelected[i] = newValue;
              reload();
            })
    ];
  }

  List<Widget> groupWidgetList() {
    return [
      for (int i = 0; i < _friends.groups.length; i++)
      ListTile(
        title: Text("Group "+ i.toString()),
        subtitle: Text(_groupToString(i)),
        leading: Icon(Icons.people),
      )
    ];
  }

  List<Widget> groupButtonList(BuildContext context) {
    return [
      for (int i = 0; i < _friends.groups.length; i++)
        ListTile(
          title: Text("Send to Group "+ i.toString()),
          subtitle: Text(_groupToString(i)),
          leading: Icon(Icons.people),
          tileColor: Theme.of(context).accentColor,
        )
    ];
  }

  String _groupToString(int index) {
    String s = "";
    for (Friend f in _friends.groups[index]) s+= f.name + ", ";
    s = s.substring(0, s.length - 2);
    return s;
  }

  void setGroupSelected(int groupIndex) {
    List<Friend> _friendsList = _friends.asList;
    _isSelected = [for (int i = 0; i < _friendsList.length; i++) false];
    for (Friend f in _friends.groups[groupIndex]) {
      int selectedIndex = _friends.groups[groupIndex].indexOf(f);
      _isSelected[selectedIndex] = true;
    }
  }
}
