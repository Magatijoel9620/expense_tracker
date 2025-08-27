// auth_toggle_page.dart
import 'package:expense_tracker/login/login_page.dart';
import 'package:expense_tracker/login/signup_page.dart';
import 'package:flutter/material.dart';

class AuthTogglePage extends StatefulWidget {
  const AuthTogglePage({Key? key}) : super(key: key);

  @override
  State<AuthTogglePage> createState() => _AuthTogglePageState();
}

class _AuthTogglePageState extends State<AuthTogglePage> {
  bool _showLoginPage = true;

  void _toggleView() {
    setState(() {
      _showLoginPage = !_showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showLoginPage) {
      return LoginPage(onSwitchToRegister: _toggleView);
    } else {
      return SignupPage(onSwitchToLogin: _toggleView);
    }
  }
}
