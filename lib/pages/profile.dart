import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/editProfile.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';

class Profile extends StatefulWidget {
  final currentUserId;

  Profile({this.currentUserId}) : super();

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  buildCountDisplay({String label, int count}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 4.0,
          ),
          child: Text(
            label,
            style: TextStyle(
                color: Colors.grey,
                fontSize: 15.0,
                fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  buildProfileButton() {
    return Text("Profile Button");
  }

  Scaffold buildUserProfilePage() {
    return Scaffold(
        appBar: Header(context, isAppTitle: false, titleText: "Profile"),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: FutureBuilder(
            future: usersRef.doc(widget.currentUserId).get(),
            builder: (context, snapshot) {
              //check if snapshot has data or not
              if (!snapshot.hasData) {
                return CircularProgress(context);
              } else if (snapshot.hasData) {
                DocumentSnapshot user = snapshot.data;
                Map<String, dynamic> userData = user.data();
                print("USER ---> $userData");
                print("UserId ---> ${widget.currentUserId}");

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 40.0,
                            backgroundImage: (userData['photoUrl'] == null)
                                ? null
                                : CachedNetworkImageProvider(
                                    userData['photoUrl']),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  buildCountDisplay(label: "posts", count: 0),
                                  buildCountDisplay(
                                      label: "followers", count: 0),
                                  buildCountDisplay(
                                      label: "following", count: 0),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [buildProfileButton()],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(
                            top: 20.0,
                          ),
                          child: Text(
                            (userData['username'] == null)
                                ? ""
                                : userData['username'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text(
                            (userData['displayName'] == null)
                                ? ""
                                : userData['displayName'],
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(top: 2.0),
                          child: Text(
                            (userData['bio'] == null) ? "" : userData['bio'],
                            style: TextStyle(
                              fontSize: 14.0,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                );
              }
              return null;
            },
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return buildUserProfilePage();
  }
}
