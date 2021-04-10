import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class LogInForm extends StatefulWidget {
  final Function toggleForm;
  final FirebaseAuth auth;

  LogInForm({this.toggleForm, this.auth});

  @override
  _LogInFormState createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  bool isPasswordObscured = true;
  IconData inputIconData = Icons.visibility;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  final _logInFormKey = GlobalKey<FormState>();

  void togglePasswordVisibility() {
    setState(() {
      isPasswordObscured = !isPasswordObscured;
    });
  }

  void toggleInputIconData() {
    if (inputIconData == Icons.visibility) {
      setState(() {
        inputIconData = Icons.visibility_off;
      });
    } else if (inputIconData == Icons.visibility_off) {
      inputIconData = Icons.visibility;
    }
  }

  final passwordValidator = MultiValidator([
    RequiredValidator(errorText: "password is required"),
    MinLengthValidator(6,
        errorText: "password must be at least 6 characters long"),
    PatternValidator(r'(?=.*?[#?!@$%^&*-])',
        errorText: 'passwords must have at least one special character')
  ]);

  final emailValidator = MultiValidator([
    RequiredValidator(errorText: "email is required"),
    EmailValidator(errorText: "please enter a valid email")
  ]);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30.0),
      child: Form(
        key: _logInFormKey,
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
                    togglePasswordVisibility();
                    toggleInputIconData();
                  },
                  child: Icon(
                    inputIconData,
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
                if (_logInFormKey.currentState.validate()) {
                  String email = _emailController.text;
                  String password = _passwordController.text;
                  try {
                    widget.auth.signInWithEmailAndPassword(
                        email: email, password: password);
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
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.tealAccent;
                  } else {
                    return Colors.white;
                  }
                }),
                minimumSize: MaterialStateProperty.all(
                  Size(
                    double.infinity,
                    50.0,
                  ),
                ),
                elevation: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.pressed)) {
                    return 0.0;
                  } else {
                    return 10.0;
                  }
                }),
                shadowColor: MaterialStateProperty.all(Colors.black),
              ),
              child: Text(
                "LOG IN",
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
                "Don't have an account? Sign up instead",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }
}
