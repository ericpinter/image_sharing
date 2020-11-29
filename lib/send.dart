import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_sharing/network/friends_selection.dart';
import 'package:image_sharing/network/network.dart';
import 'package:image_sharing/network/friends_model.dart';
import 'package:image_sharing/network/network_utils.dart';

class SendTab extends StatefulWidget {
  NetworkLog log;

  SendTab(this.log);

  @override
  State<StatefulWidget> createState() => _SendTabState(log);
}

class _SendTabState extends State<SendTab> {
  PickedFile _image;
  NetworkLog log;
  final picker = ImagePicker();
  FriendsSelection selection;

  _SendTabState(this.log) {
    selection = FriendsSelection(Friends(), reload);
  }

  reload() {
    setState(() {});
  }

  // adapted from https://medium.com/fabcoding/adding-an-image-picker-in-a-flutter-app-pick-images-using-camera-and-gallery-photos-7f016365d856
  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        getImage(ImageSource.gallery);
                        Navigator.pop(context);
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      getImage(ImageSource.camera);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future getImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = pickedFile;
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_image == null && selection == null) {
      //learned about from https://stackoverflow.com/questions/49466556/flutter-run-method-on-widget-build-complete
      //we have to delay this to run after the build finishes for annoying reasons
      Future.delayed(Duration.zero, () => _showPicker(context));
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Send An Image"),
        ),
        body: Center(
            child: ListView(children: [
              Hero(
                  tag: "post",
                  child: ElevatedButton(
                      onPressed: () => _showPicker(context),
                      child: Text("Change Image"))
              ),
              _image == null
                  ? Text('No image selected.')
                  : PickedFileToWidget(_image),
              for(Widget w in generateGroupButtons()) w,
              for (Widget friend_widget in selection
                  .asWidgetList()) friend_widget,
              ElevatedButton(
                  onPressed: () async {
                    var selected = selection.selected();
                    if (selected.isNotEmpty && _image != null) {
                      print(_image.path);
                      log.sendImage(selected, _image);
                      Navigator.pop(context);
                    } else return noSelectionAlert(context);
                  },
                  child: Text("Submit"))
            ])));
  }

  Widget noSelectionAlert(BuildContext context) {
    Widget button = FlatButton(
      child: Text("OK"),
      onPressed: () => Navigator.of(context).pop(),
    );

    showDialog (
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("No Friends Selected"),
          content: Text("Please select a friend to send to"),
          actions: [button],
        );
      },
    );
  }

  List<Widget> generateGroupButtons() {
    List<Widget> buttonList = selection.groupButtonList(context);
    List<Widget> groupButtons = [
      for (int i = 0; i < buttonList.length; i++) groupButton(buttonList[i], i)
    ];
    return groupButtons;
  }

  Widget groupButton(Widget groupTile, int index) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: GestureDetector(
        child: groupTile,
        onTap: () {
          if (_image != null) {
            selection.setGroupSelected(index);
            var selected = selection.selected();
            print(_image.path);
            log.sendImage(selected, _image);
            Navigator.pop(context);
          } else return noSelectionAlert(context);
        }
      )
    );
  }
}
