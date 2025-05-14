import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auth/presenatiton/pages/sign_in_page.dart';
import 'package:flutter_application_1/features/auth/presenatiton/pages/sign_up_page.dart';

class AuthPages extends StatefulWidget {
  const AuthPages({super.key});

  @override
  State<AuthPages> createState() => _AuthPagesState();
}

class _AuthPagesState extends State<AuthPages> {
  bool showSignInPage = true;

  void togglePages() {
    setState(() {
      showSignInPage = !showSignInPage;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (showSignInPage) {
      return SigninPage(onTap: togglePages,);
    } else {
      return SignUpPage(onTap: togglePages);
    }
  }
}

class SignupPage {
}