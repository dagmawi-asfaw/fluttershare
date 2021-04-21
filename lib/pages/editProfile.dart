import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:form_field_validator/form_field_validator.dart';

class EditProfile extends StatefulWidget {
  final currentUserId;

  EditProfile({this.currentUserId}) : super();

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
  TextEditingController displayNameController;
  TextEditingController bioController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  handleLogout() {
    //log out user and return them to home
    FirebaseAuth.instance.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Home()
      ),
    );
  }

  handleProfileUpdate() async {
    Map<String, dynamic> updatePayload;
    if (displayNameController.text != "" && bioController.text != "") {
      updatePayload = {
        "displayName": displayNameController.text.trim(),
        "bio": bioController.text.trim()
      };
    } else if (displayNameController.text != "" && bioController.text == "") {
      updatePayload = {
        "displayName": displayNameController.text.trim(),
      };
    } else if (displayNameController.text == "" && bioController.text != "") {
      updatePayload = {
        "bio": bioController.text.trim(),
      };
    } else if (displayNameController.text == "" && bioController.text == "") {
      SnackBar snackBar = SnackBar(
        content: Text(
          "You have not made any changes to your profile",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 8.0,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    await usersRef.doc(widget.currentUserId).update(updatePayload);
    SnackBar snackBar = SnackBar(
      content: Text(
        "Your profile has been updated",
        style: TextStyle(
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.white,
      elevation: 8.0,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget buildDisplayNameTextField() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Display Name",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
            ),
          ),
          Center(
            child: Container(
              width: 500,
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: displayNameController,
                validator: MinLengthValidator(4,
                    errorText: "At least Four Characters are required"),
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBioTextField() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bio",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
            ),
          ),
          Center(
            child: Container(
              width: 500.0,
              child: TextFormField(
                validator: MaxLengthValidator(100,
                    errorText: "A maximum of 100 characters allowed"),
                controller: bioController,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    displayNameController = TextEditingController();
    bioController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {
              //return to previous screen
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.check,
              color: Colors.green,
              size: 30.0,
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: usersRef.doc(widget.currentUserId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgress(context);
          } else {
            DocumentSnapshot user = snapshot.data;
            Map<String, dynamic> userData = user.data();
            return ListView(
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(
                    top: 25.0,
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.orange,
                    radius: 60.0,
                    backgroundImage: (userData['photoUrl'] == null)
                        ? null
                        : CachedNetworkImageProvider(userData['photoUrl']),
                  ),
                ),
                buildDisplayNameTextField(),
                buildBioTextField(),
                SizedBox(
                  height: 20.0,
                ),
                Center(
                  child: Container(
                    width:
                        (orientation == Orientation.portrait) ? 150.0 : 450.0,
                    height: 50.0,
                    child: ElevatedButton(
                      onPressed: handleProfileUpdate,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith(
                          (states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.grey.shade500;
                            } else {
                              return Colors.grey.shade300;
                            }
                          },
                        ),
                        elevation: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.pressed)) {
                            return 0.0;
                          } else {
                            return 10.0;
                          }
                        }),
                      ),
                      child: Text(
                        "Update Profile",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Center(
                  child: SizedBox(
                    width:
                        (orientation == Orientation.portrait) ? 150.0 : 450.0,
                    height: 40.0,
                    child: ElevatedButton(
                      onPressed: handleLogout,
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                            EdgeInsets.all(
                              5.0,
                            ),
                          ),
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                            side: BorderSide(
                              color: Colors.red,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(
                              8.0,
                            ),
                          )),
                          elevation:
                              MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.pressed)) {
                              return 0.0;
                            } else {
                              return 10.0;
                            }
                          }),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cancel_rounded,
                            color: Colors.red,
                            size: 24.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 5.0,
                            ),
                            child: Text(
                              "Log out",
                              style:
                                  TextStyle(color: Colors.red, fontSize: 18.0),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    displayNameController.dispose();
    bioController.dispose();
  }
}
