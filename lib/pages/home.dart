import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttershare/pages/activityFeed.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:fluttershare/widgets/logInForm.dart';
import 'package:fluttershare/widgets/signUpForm.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool showLogin = false;
  PageController _pageController = PageController(initialPage: 0);
  int currentBottomNavBarIndex = 0;

  void toggleUserForm({bool showLogin, bool showSignUp}) {
    setState(
      () {
        this.showLogin = !this.showLogin;
      },
    );
  }

  void createUserInFireStore({User user, String userName}) {
    String id = user.uid;
    String username = userName;
    String email = user.email;
    String displayName = user.displayName;
    String bio = "";
    DateTime timestamp = DateTime.now();
    usersRef.add({
      'id':id,
      'username':username,
      'email': email,
      'displayName':displayName,
      'bio': bio,
      'timestamp': timestamp.toString()
    }).catchError((error){
      print("Failed to add user : $error");
    });
  }

  Widget buildAuthenticatedScreen() {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Timeline(),
          ActivityFeed(),
          Upload(),
          Search(),
          Profile(),
        ],
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: currentBottomNavBarIndex,
        activeColor: Theme.of(context).primaryColor,
        onTap: (int pageIndex) {
          setState(
            () {
              //update current navbar index
              this.currentBottomNavBarIndex = pageIndex;

              //go to specified page
              _pageController.animateToPage(
                pageIndex,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          );
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_camera,
              size: 40.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
    );
  }

  Scaffold buildUnauthenticatedScreen() {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints(minWidth: double.infinity),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor,
            ])),
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 150.0,
                ),
                Text(
                  "flutter share",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Signatra",
                    fontSize: 90.0,
                    color: Colors.white,
                  ),
                ),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 1),
                  child: this.showLogin
                      ? LogInForm(
                          toggleForm: toggleUserForm,
                          auth: this.auth,
                        )
                      : SignUpForm(
                          toggleForm: toggleUserForm,
                          auth: this.auth,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    Future<void> signOut() async {
      auth.signOut();
    }

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user != null) {
        setState(() {
          isAuth = true;
        });
      } else if (user != null) {
        setState(() {
          isAuth = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthenticatedScreen() : buildUnauthenticatedScreen();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _pageController.dispose();
  }
}
