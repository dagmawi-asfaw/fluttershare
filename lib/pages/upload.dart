import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
  final User currentUser;

  Upload({this.currentUser}) : super();
}

class _UploadState extends State<Upload> {
  File file;
  final picker = ImagePicker();
  bool isUploading = false;
  String postId = Uuid().v4();
  TextEditingController captionController;

  TextEditingController locationController;

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

  clearPickedImage() {
    //set file to null to go back to upload screen
    setState(() {
      this.file = null;
    });
  }

  compressImage() async {
    // get a temporary directory
    final tempDir = await getTemporaryDirectory();
    final tempDirPath = tempDir.path;

    //read the image File
    Im.Image imageFile = Im.decodeImage(this.file.readAsBytesSync());

    //compress the image file
    final compressedImageFile = File('$tempDirPath/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));

    //update the state with the compressed image
    setState(() {
      this.file = compressedImageFile;
    });
  }

  Future<String> uploadImage({imageFile}) async {
    //get storage bucket url
    Reference storageUrl = FirebaseStorage.instance.ref();

    //create a future to  upload the compressed image file
    UploadTask uploadTask = storageUrl
        .child('postImages')
        .child('post_$postId.jpg')
        .putFile(imageFile);

    try {
      //ACTUALLY UPLOAD THE IMAGE HERE
      TaskSnapshot taskSnapshot = await uploadTask;
    } catch (e) {
      print("Error during image upload: $e");
      print(uploadTask.snapshot);
    }

    //check the status of the upload task
    String imageDownloadUrl = await storageUrl
        .child('postImages')
        .child('post_$postId.jpg')
        .getDownloadURL();

    return imageDownloadUrl;
  }

  handlePostSubmit() async {
    setState(() {
      this.isUploading = true;
    });
    compressImage();
    String imageDownloadUrl = await uploadImage(imageFile: this.file);
    String location = locationController.text;
    String description = captionController.text;

    //createPost
    await createPostInFireStore(
        mediaUrl: imageDownloadUrl,
        description: description,
        location: location);
    setState(() {
      //clear TextFields
      locationController.clear();
      captionController.clear();

      //set isUploading to false because uploading is finished
      this.isUploading = false;

      //generate a new postId
      this.postId = Uuid().v4();

      //clear the picked file
      clearPickedImage();
    });
  }

  Future<void> createPostInFireStore(
      {String mediaUrl, String description, String location}) async {
    CollectionReference postsRef =
        FirebaseFirestore.instance.collection('posts');
    await postsRef
        .doc('${widget.currentUser.uid}')
        .collection('userPosts')
        .doc("$postId")
        .set(
      {
        "postId": postId,
        "ownerId": widget.currentUser.uid,
        "ownerName": widget.currentUser.displayName,
        "mediaUrl": mediaUrl,
        "description": description,
        "location": location,
        "timestamp": DateTime.now(),
        "likes": ""
      },
    );
  }

  getUserLocation() async {
    //ask for permission
    PermissionStatus status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      //check if location services are enabled
      if (isServiceEnabled) {
        //get current location of user
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        //get place mark from user location coordinates
        List<Placemark> placeMarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        Placemark placeMark = placeMarks[0];

        String formatedLocation = "${placeMark.locality}, ${placeMark.country}";

        locationController.text = formatedLocation;
      } else {
        return Future.error("Location services are disabled");
      }
    } else if ((status == PermissionStatus.permanentlyDenied)) {
      return Future.error(
          "Location permissions are permanently denied, we cannot request permissions.");
    }
  }

  buildUploadForm() {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          shadowColor: Colors.black,
          elevation: 8.0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.black,
            onPressed: () => clearPickedImage(),
          ),
          title: Text(
            "Caption Post",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: isUploading ? null : handlePostSubmit,
              child: Text(
                "post",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            )
          ],
        ),
        body: ListView(
          children: [
            isUploading ? LinearProgress(context) : SizedBox(),
            Container(
              padding: EdgeInsets.all(5.0),
              height: 220.0,
              width: MediaQuery.of(context).size.width * 0.8,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image(
                  image: FileImage(this.file),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    CachedNetworkImageProvider(widget.currentUser.photoURL),
              ),
              title: Container(
                width: 250.0,
                child: TextField(
                  controller: captionController,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                  decoration: InputDecoration(
                    hintText: "write a caption ..",
                    hintStyle: TextStyle(
                      color: Colors.black54,
                    ),
                    border: UnderlineInputBorder(),
                  ),
                ),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(
                Icons.pin_drop,
                color: Colors.orange,
                size: 35.0,
              ),
              title: Container(
                width: 250.0,
                child: TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: "Where was this photo taken?",
                    hintStyle: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 200.0,
              height: 100.0,
              alignment: Alignment.center,
              child: ElevatedButton.icon(
                onPressed: getUserLocation,
                icon: Icon(
                  Icons.my_location,
                  color: Colors.white,
                ),
                label: Text(
                  "use my current location",
                  style: TextStyle(color: Colors.white),
                ),
                style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(
                      Size(
                        40.0,
                        45.0,
                      ),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.blueAccent),
                    elevation: MaterialStateProperty.resolveWith(
                      (states) {
                        if (states.contains(MaterialState.pressed)) {
                          return 4.0;
                        }
                        return 8.0;
                      },
                    ),
                    shadowColor: MaterialStateProperty.all(Colors.black)),
              ),
            ),
          ],
        ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    captionController = TextEditingController();
    locationController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return (this.file == null) ? buildSplashScreen() : buildUploadForm();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    captionController.dispose();
    locationController.dispose();
  }
}
