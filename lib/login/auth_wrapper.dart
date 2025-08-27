// auth_wrapper.dart
import 'package:expense_tracker/auth/auth_service.dart';
import 'package:expense_tracker/login/auth_toggle_page.dart';
import 'package:expense_tracker/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/data/expense_data.dart'; // Import ExpenseData

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false); // Can set listen:false if only using stream
    final expenseData = Provider.of<ExpenseData>(context, listen: false); // Get ExpenseData

    return StreamBuilder<User?>(
      stream: authService.authStateChanges, // Listen to auth state
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator())); // Loading state
        }
        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in
          // Trigger data load for the logged-in user
          // Important: Ensure this doesn't cause rapid repeated calls if stream rebuilds often.
          // A flag in ExpenseData or a more sophisticated state management might be needed for complex scenarios.
          expenseData.prepareData(); // Call prepareData here
          return const HomePage();
        } else {
          // User is logged out

          //expenseData.clearAllExpensesLocally(); // Add a method to clear local data on logout
          return const AuthTogglePage();
        }
      },
    );
  }
}