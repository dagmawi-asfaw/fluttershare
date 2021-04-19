import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class SignUpForm extends StatefulWidget {
  final Function toggleForm;
  final FirebaseAuth auth;

  SignUpForm({this.toggleForm, this.auth});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool isPasswordObscured = true;
  bool isConfirmPasswordObscured = true;
  IconData passwordIconData = Icons.visibility;
  IconData confirmPasswordIconData = Icons.visibility;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  final _signUpFormKey = GlobalKey<FormState>();

  void togglePasswordVisibility({bool isConfirmPass}) {
    setState(() {
      if (!isConfirmPass) {
        isPasswordObscured = !isPasswordObscured;
      } else {
        isConfirmPasswordObscured = !isConfirmPasswordObscured;
      }
    });
  }

  void toggleInputIconData({bool isConfirmPass}) {
    if (!isConfirmPass) {
      if (passwordIconData == Icons.visibility) {
        setState(() {
          passwordIconData = Icons.visibility_off;
        });
      } else if (passwordIconData == Icons.visibility_off) {
        passwordIconData = Icons.visibility;
      }
    } else {
      if (confirmPasswordIconData == Icons.visibility) {
        setState(() {
          confirmPasswordIconData = Icons.visibility_off;
        });
      } else if (confirmPasswordIconData == Icons.visibility_off) {
        confirmPasswordIconData = Icons.visibility;
      }
    }
  }

  final emailValidator = MultiValidator([
    RequiredValidator(errorText: "email is required"),
    EmailValidator(errorText: "please enter a valid email"),
  ]);

  final usernameValidator = MultiValidator([
    RequiredValidator(errorText: "user name is required"),
    MinLengthValidator(5,
        errorText: "username must have at least 5 characters ")
  ]);

  final passwordValidator = MultiValidator([
    RequiredValidator(errorText: "password is required"),
    MinLengthValidator(6,
        errorText: "password must be at least 6 characters long"),
    PatternValidator(r'(?=.*?[#?!@$%^&*-])',
        errorText: 'passwords must have at least one special character')
  ]);

  String confirmPassValidator(value) {
    if (value == null || value == "") {
      return "please retype the password";
    } else if (_passwordController.text != _confirmPasswordController.text) {
      return "passwords do not match please try again";
    }
    return null;
  }

  void createUserInFireStore({User user, String userName}) {
    String id = user.uid;
    String username = userName;
    String email = user.email;
    String displayName = user.displayName;
    String bio = "";
    String photoUrl = user.photoURL;
    DateTime timestamp = DateTime.now();
    FirebaseFirestore.instance.collection("users").add({
      'id': id,
      'username': username,
      'email': email,
      'displayName': displayName,
      'bio': bio,
      'photoUrl': photoUrl,
      'timestamp': timestamp.toString(),
    }).catchError((error) {
      print("Failed to add user : $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30.0),
      child: Form(
        key: _signUpFormKey,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                validator: emailValidator,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(
                    fontSize: 15.0,
                    color: Colors.white,
                  ),
                  fillColor: Theme.of(context).primaryColorLight,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              TextFormField(
                controller: _usernameController,
                validator: usernameValidator,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
                decoration: InputDecoration(
                  labelText: "Username ",
                  labelStyle: TextStyle(
                    fontSize: 15.0,
                    color: Colors.white,
                  ),
                  fillColor: Theme.of(context).primaryColorLight,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              TextFormField(
                controller: _passwordController,
                validator: passwordValidator,
                obscureText: isPasswordObscured,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
                decoration: InputDecoration(
                  labelText: "Password",
                  suffix: InkWell(
                    onTap: () {
                      togglePasswordVisibility(isConfirmPass: false);
                      toggleInputIconData(isConfirmPass: false);
                    },
                    child: Icon(
                      passwordIconData,
                      color: Colors.white,
                    ),
                  ),
                  labelStyle: TextStyle(
                    fontSize: 15.0,
                    color: Colors.white,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                validator: confirmPassValidator,
                obscureText: isConfirmPasswordObscured,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
                decoration: InputDecoration(
                  labelText: "Confirm password",
                  suffix: InkWell(
                    onTap: () {
                      togglePasswordVisibility(isConfirmPass: true);
                      toggleInputIconData(isConfirmPass: true);
                    },
                    child: Icon(
                      confirmPasswordIconData,
                      color: Colors.white,
                    ),
                  ),
                  labelStyle: TextStyle(
                    fontSize: 15.0,
                    color: Colors.white,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_signUpFormKey.currentState.validate()) {
                    String email = _emailController.text;
                    String password = _passwordController.text;
                    String username = _usernameController.text;

                    //check if the user exists

                    try {
                      widget.auth
                          .createUserWithEmailAndPassword(
                              email: email, password: password)
                          .then((UserCredential userCred) {
                        //save user to database
                        print("USER CRED --> ${userCred.user}");
                        createUserInFireStore(
                            user: userCred.user, userName: username);
                      });
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        print('The password provided is too weak.');
                      } else if (e.code == 'email-already-in-use') {
                        print('The account already exists for that email.');
                      }
                    } catch (e) {
                      print(e);
                    }
                  }
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.white;
                      } else {
                        return Colors.tealAccent;
                      }
                    }),
                    elevation: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return 0.0;
                      } else {
                        return 10.0;
                      }
                    }),
                    shadowColor: MaterialStateProperty.all(Colors.black),
                    minimumSize:
                        MaterialStateProperty.all(Size(double.infinity, 50.0))),
                child: Text(
                  "SIGN UP",
                  style: TextStyle(
                      fontSize: 18,
                      letterSpacing: 1.5,
                      color: Theme.of(context).primaryColor),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              GestureDetector(
                onTap: () {
                  widget.toggleForm();
                },
                child: Text(
                  "Already have an account? Log in instead",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ]),
      ),
    );
  }

  @override
  void dispose() {
     super.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _confirmPasswordController.dispose();
  }
}
