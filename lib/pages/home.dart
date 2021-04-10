import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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

  Widget loadingScreen() {
    return Scaffold(
      body: Container(
        child: SpinKitFadingCircle(
          color: Theme.of(context).primaryColor,
          size: 80.0,
        ),
      ),
    );
  }

  void toggleUserForm({bool showLogin, bool showSignUp}) {
    setState(() {
      this.showLogin = !this.showLogin;
    });
    print("I AM TRIGGERED ${this.showLogin}");
  }

  Widget buildAuthenticatedScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        alignment: Alignment.center,
        child: TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue),
          ),
          onPressed: () {
            auth.signOut();
            setState(() {
              isAuth = false;
            });
          },
          child: Text(
            "Log out",
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
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
          print("User Authenticated $user");
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
}
