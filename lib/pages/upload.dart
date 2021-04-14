import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File file;
  final picker = ImagePicker();

  Future<void> handleChoosePhotoFromGallery() async {
    PickedFile pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        this.file = File(pickedFile.path);
      });
    } else if (pickedFile == null) {
      print("No Image picked");
    }
    Navigator.pop(context);
  }

  Future<void> handleTakePhoto() async {
    PickedFile pickedFile = await picker.getImage(
      source: ImageSource.camera,
      maxHeight: 960,
      maxWidth: 675,
    );
    if (pickedFile != null) {
      setState(() {
        this.file = File(pickedFile.path);
      });
    } else if (pickedFile == null) {
      print("No Image picked");
    }
    Navigator.pop(context);
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            "Create Post",
            style: TextStyle(fontSize: 22.0),
          ),
          children: [
            SimpleDialogOption(
              onPressed: handleTakePhoto,
              child: Text("Photo with camera"),
            ),
            SimpleDialogOption(
              onPressed: handleChoosePhotoFromGallery,
              child: Text("Photo from gallery"),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Container buildSplashScreen() {
    final Orientation _orientation = MediaQuery.of(context).orientation;

    return Container(
      color: Theme.of(context).primaryColorLight.withOpacity(0.8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: SvgPicture.asset(
              'assets/images/upload.svg',
              semanticsLabel: "upload",
              height: (_orientation == Orientation.portrait) ? 300.0 : 150.0,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: ElevatedButton(
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(
                  Size(35.0, 60.0),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                backgroundColor: MaterialStateProperty.resolveWith(
                  (states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.deepOrangeAccent;
                    }
                    return Colors.deepOrange;
                  },
                ),
                elevation: MaterialStateProperty.resolveWith(
                  (states) {
                    if (states.contains(MaterialState.pressed)) {
                      return 4.0;
                    }
                    return 8.0;
                  },
                ),
                shadowColor: MaterialStateProperty.all(Colors.black),
              ),
              onPressed: () => selectImage(context),
              child: Text(
                "Upload Image",
                style: TextStyle(
                    color: Colors.white, fontSize: 22.0, letterSpacing: 1.5),
              ),
            ),
          )
        ],
      ),
    );
  }

  buildUploadForm() {
    return Text("file has been uploaded or picked I don't know yet");
  }

  @override
  Widget build(BuildContext context) {
    return (this.file == null) ? buildSplashScreen() : buildUploadForm();
  }
}
