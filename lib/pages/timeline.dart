import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:form_field_validator/form_field_validator.dart';

// get a reference the collection we want
final CollectionReference usersRef =
    FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  void getUsers() async {
    QuerySnapshot usersDoc = await usersRef.get();

    usersDoc.docs.forEach((DocumentSnapshot doc) {
      print(doc.data());
    });
  }

  void getDocumentById({String documentId}) async {
    DocumentSnapshot doc = await usersRef.doc(documentId).get();
    print(doc.data());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(context, isAppTitle: true),
      body: Container(
          alignment: Alignment.center,
          child: StreamBuilder<QuerySnapshot>(
            stream: usersRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgress(context);
              }

              //map it to another list of list tiles
              //future builder for one snapshot
              //stream builder for getting new snapshots as documents get added

              List<ListTile> children = snapshot.data.docs.map(
                (doc) {
                  return ListTile(
                    title: Text(
                      doc['username'],
                      style: TextStyle(fontSize: 40.0),
                    ),
                  );
                },
              ).toList();

              return ListView(
                children: children,
              );
            },
          )),
    );
  }
}


