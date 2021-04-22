import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/editProfile.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';

class Profile extends StatefulWidget {
  final currentUserId;

  Profile({this.currentUserId}) : super();

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
  CollectionReference postsRef = FirebaseFirestore.instance.collection("posts");

  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];

  int getLikeCount({Map post}) {
    int likeCount = 0;

    if (post['likes'].length != 0) {
      post['likes'].forEach((user) {
        if (user.hasLiked == true) {
          likeCount++;
        }
      });
    }

    return likeCount;
  }

  getProfilePosts() async {
    setState(() {
      this.isLoading = true;
    });

    DocumentSnapshot userDoc = await usersRef.doc(widget.currentUserId).get();
    Map<String, dynamic> userData = userDoc.data();

    QuerySnapshot postDocs = await postsRef
        .doc(widget.currentUserId)
        .collection("userPosts")
        .orderBy("timestamp", descending: true)
        .get();

    List<Post> tempPosts = [];
    postDocs.docs.forEach((post) {
      Map<String, dynamic> postData = post.data();
      int likeCount = getLikeCount(post: postData);
      tempPosts.add(Post(
        postId: postData['postId'],
        ownerId: postData['ownerId'],
        mediaUrl: postData['mediaUrl'],
        location: postData['location'],
        description: postData["description"],
        likeCount: likeCount,
        username: userData['username'],
      ));
    });

    setState(() {
      this.isLoading = false;
      this.postCount = postDocs.docs.length;
      this.posts = tempPosts;
    });
  }

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
    if (widget.currentUserId == FirebaseAuth.instance.currentUser.uid) {
      return Center(
        child: Container(
          width: 200.0,
          padding: EdgeInsets.all(10.0),
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfile(
                  currentUserId: widget.currentUserId,
                ),
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
              elevation: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.pressed)) {
                  return 0.0;
                } else {
                  return 10.0;
                }
              }),
            ),
            child: Text(
              "Edit Profile",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }
    return Center(
      child: Container(
        width: 200.0,
        padding: EdgeInsets.all(10.0),
        child: ElevatedButton(
          onPressed: () {
            print("Followed User");
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white),
            elevation: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return 0.0;
              } else {
                return 10.0;
              }
            }),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.black,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(
                8.0,
              ),
            )),
          ),
          child: Text(
            "Follow",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
    ;
  }

  Widget buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 10.0),
      child: FutureBuilder(
        future: usersRef.doc(widget.currentUserId).get(),
        builder: (context, snapshot) {
          //check if snapshot has data or not
          if (!snapshot.hasData) {
            return CircularProgress(context);
          }
          DocumentSnapshot user = snapshot.data;
          Map<String, dynamic> userData = user.data();

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
                          : CachedNetworkImageProvider(userData['photoUrl']),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildCountDisplay(
                                label: "posts", count: this.postCount),
                            buildCountDisplay(label: "followers", count: 0),
                            buildCountDisplay(label: "following", count: 0),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
        },
      ),
    );
  }

  Widget buildProfilePosts() {
    return Column(
      children: this.posts,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getProfilePosts();
    return Scaffold(
      appBar: Header(context, isAppTitle: false, titleText: "Profile"),
      body: ListView(
        children: [
          buildProfileHeader(),
          Divider(),
          buildProfilePosts(),
        ],
      ),
    );
  }
}
