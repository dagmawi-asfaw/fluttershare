import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/progress.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String mediaUrl;
  final String location;
  final String description;
  final int likeCount;
  final String username;

  Post({
    this.postId,
    this.ownerId,
    this.mediaUrl,
    this.location,
    this.description,
    this.likeCount,
    this.username,
  }) : super();

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  CollectionReference postsRef = FirebaseFirestore.instance.collection("posts");
  CollectionReference usersRef = FirebaseFirestore.instance.collection("users");

  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.doc(widget.ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgress(context);
        }
        DocumentSnapshot userDoc = snapshot.data;
        Map<String, dynamic> userData = userDoc.data();
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userData["photoUrl"]),
            backgroundColor: Colors.grey,
            radius: 28.0,
          ),
          title: GestureDetector(
            onTap: () {
              print("showing profile");
            },
            child: Text(
              (userData['username'] != " ") ? userData['username'] : "",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
            ),
          ),
          subtitle: Text(
            (widget.location != " ") ? widget.location : "",
            style: TextStyle(color: Colors.black54),
          ),
          trailing: IconButton(
            onPressed: () {
              print("deleting profile");
            },
            icon: Icon(
              Icons.more_vert,
              color: Colors.blueAccent,
            ),
          ),
        );
      },
    );
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: () {
        print("liking post");
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(widget.mediaUrl),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: IconButton(
              icon: Icon(
                Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
              onPressed: () {
                print("liking post");
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: IconButton(
              icon: Icon(
                Icons.message,
                size: 28.0,
                color: Colors.blue[900],
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Row(
          children: [
            Text(
              "${widget.likeCount.toString()} likes",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Row(
          children: [
            Text(
              "${widget.username}",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(child: Text(widget.description))
          ],
        ),
      ),
    ]);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}
