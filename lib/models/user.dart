import 'package:firebase_auth/firebase_auth.dart';

class User {
  final String id;

  final String username;
  final String email;

  final String displayName;
  final String bio;

  final String photoUrl;

  User(
      {this.id,
      this.username,
      this.displayName,
      this.email,
      this.bio,
      this.photoUrl});
}
