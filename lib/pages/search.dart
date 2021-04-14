import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Future<QuerySnapshot> searchResults;
  TextEditingController _searchFieldController;

  void handleSubmit(String query) {
    Future<QuerySnapshot> users = usersRef
        .where("username", isGreaterThanOrEqualTo: query)
        .where("username", isLessThanOrEqualTo: query)
        .get();

    setState(() {
      searchResults = users;
    });
  }

  FutureBuilder buildSearchResults(BuildContext context) {
    return FutureBuilder(
      future: searchResults,
      builder: (context, snapshots) {
        if (!snapshots.hasData) {
          return CircularProgress(context);
        }
        List<UserResult> results = [];
        snapshots.data.docs.forEach((QueryDocumentSnapshot user) {
          User _user = User(
            id: user.data()['id'],
            displayName: user.data()['displayName'],
            username: user.data()['username'],
            email: user.data()['email'],
            bio: user.data()['bio'],
            photoUrl: user.data()['photoUrl'],
          );

          results.add(UserResult(
            userData: _user,
          ));
        });

        return Container(
          color: Theme.of(context).primaryColorLight,
          child: ListView(
            children: results,
          ),
        );
      },
    );
  }

  void clearSearchField() {
    _searchFieldController.clear();
  }

  AppBar buildSearchField(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextField(
        controller: _searchFieldController,
        onSubmitted: handleSubmit,
        decoration: InputDecoration(
            focusColor: Theme.of(context).accentColor,
            hintText: "Search for a user here...",
            fillColor: Colors.grey.shade400,
            filled: true,
            prefixIcon: Icon(
              Icons.account_box,
              size: 28.0,
            ),
            suffixIcon: IconButton(
              onPressed: clearSearchField,
              icon: Icon(
                Icons.clear,
              ),
            )),
      ),
    );
  }

  Container buildNoContent(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight,
      ),
      child: Center(
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: (orientation == Orientation.portrait) ? 60.0 : 15.0,
              ),
              child: SvgPicture.asset(
                "assets/images/search.svg",
                semanticsLabel: "Search",
                height: (orientation == Orientation.portrait) ? 300.0 : 150.0,
              ),
            ),
            Text(
              "Find users",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: (orientation == Orientation.portrait) ? 60.0 : 40.0,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _searchFieldController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearchField(context),
      body: (searchResults == null)
          ? buildNoContent(context)
          : buildSearchResults(context),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _searchFieldController.dispose();
  }
}

class UserResult extends StatelessWidget {
  final User userData;

  UserResult({this.userData});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              print("I have been tapped");
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(
                  this.userData.photoUrl,
                ),
              ),
              title: Text(
                (this.userData.displayName == null)
                    ? "None"
                    : this.userData.displayName,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              subtitle: Text(
                (this.userData.username == null)
                    ? "None"
                    : this.userData.username,
                style: TextStyle(
                  color: Colors.white,
                  height: 2.0,
                ),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
            thickness: 2.0,
          )
        ],
      ),
    );
  }
}
