import 'dart:io';
import 'package:flutter/scheduler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SendTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SendTabState();
}

class _SendTabState extends State<SendTab> {
  File _image;
  final picker = ImagePicker();

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
        _image = File(pickedFile.path);
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
    return Scaffold(
        appBar: AppBar(
          title: Text("Send An Image"),
        ),
        body: Center(
            child: Column(children: [
          Hero(
              tag: "post",
              child: ElevatedButton(
                  onPressed: () => _showPicker(context),
                  child: Text("Change Image"))),
          _image == null ? Text('No image selected.') : Image.file(_image),
        ])));
  }
}
