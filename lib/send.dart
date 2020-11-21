import 'dart:io';
import 'package:flutter/scheduler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_sharing/network/network.dart';
import 'package:image_sharing/network/friends_model.dart';

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
  String friend_selection;

  _SendTabState(this.log);

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
    if (_image == null) {
      //learned about from https://stackoverflow.com/questions/49466556/flutter-run-method-on-widget-build-complete
      //we have to delay this to run after the build finishes for annoying reasons
      Future.delayed(Duration.zero, () => _showPicker(context));
    }
    final _formKey = GlobalKey<FormState>();
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
                    child: Text("Change Image"))),
            _image == null ? Text('No image selected.') : Image.file(File(_image.path)),
            Form(
                key: _formKey,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  validator: ipValidate,
                  onSaved: (text) {
                    friend_selection = text;
                  },
                )),
            ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    print(_image.path);
                    _formKey.currentState.save();
                    await log.sendImage(Friend(friend_selection), _image);
                    Navigator.pop(context);
                  }
                },
    child: Text("Submit"))]

    )
    )
    );
  }

  String ipValidate(String value) {
    if (value.isEmpty) {
      return 'Please enter an IP address';
    }
    else {
      List<String> splitList = value.split('.');
      if (splitList.length != 4) return "Invalid IP Address";
      for (String substring in splitList) {
        if (!isNumeric(substring)) return "Invalid IP Address";
        int num = int.parse(substring);
        if (num < 0 || num > 255) return "Invalid IP Address";
      }
    }
    return null;
  }

  bool isNumeric(String str) {
    return double.tryParse(str) != null;
  }
}
