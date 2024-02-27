import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added this line
import 'package:cloud_firestore/cloud_firestore.dart'; // Added this line
import '../../components/background.dart';
import 'components/sign_up_top_image.dart';
import 'components/signup_form.dart';
import 'components/socal_sign_up.dart';
import 'components/social_icon.dart';
import '../../Notes.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);


  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Background(
      child: SingleChildScrollView(
        child: MobileSignupScreen(), // Removed Responsive widget
      ),
    );
  }
}

class MobileSignupScreen extends StatelessWidget {
  const MobileSignupScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SignUpScreenTopImage(),
        SizedBox(height: 20),
        SignUpForm(),
      ],
    );
  }

  void signUp(String email, String password, String fullName, BuildContext context) async {
    try {
      final auth = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      postDetailsToFirestore(email, fullName, context);
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

  void postDetailsToFirestore(String email, String fullName, BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    Map<String, dynamic> userData = {
      'fullName': fullName,
      'email': email,
    };

    FirebaseFirestore.instance.collection('users').doc(user?.uid).set(userData)
        .then((value) {
      print('User data uploaded successfully!');
    }).catchError((error) {
      print('Error uploading user data: $error');
    });

    Fluttertoast.showToast(msg: "Account created successfully :) ");
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NotesPage()));
  }
}
