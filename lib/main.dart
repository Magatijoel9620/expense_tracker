// main.dart (Corrected)
import 'package:expense_tracker/data/expense_data.dart';
import 'package:expense_tracker/login/auth_wrapper.dart';
import 'package:expense_tracker/pages/home_page.dart';
import 'package:expense_tracker/theme_provider.dart'; // Import ThemeProvider
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
//import 'firebase_options.dart';
import 'package:expense_tracker/auth/auth_service.dart'; // Import AuthService

void main() async {
  // WidgetsFlutterBinding.ensureInitialized(); // Required for Firebase
  // await Firebase.initializeApp( // Initialize Firebase
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // initialize hive
  await Hive.initFlutter();
  // open a hive box
  await Hive.openBox("expense_database");

  runApp(const MyApp()); // Keep this simple
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide ThemeProvider first, at a higher level or alongside ExpenseData
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ExpenseData()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
       // ChangeNotifierProvider(create: (context) => AuthService()),
      ],
      // The Consumer for ThemeProvider now correctly sits under MultiProvider
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // The 'context' here now has access to BOTH ExpenseData and ThemeProvider
          // because MultiProvider is above this Consumer in the widget tree.

          // You can also access ExpenseData here if needed, e.g.:
          // final expenseData = Provider.of<ExpenseData>(context, listen: false);

          return MaterialApp(
            //change MaterialApp's home to AuthWrapper

            debugShowCheckedModeBanner: false,
            title: 'Expense Tracker', // Added a title
            theme: ThemeProvider.lightTheme,     // Your light theme
            darkTheme: ThemeProvider.darkTheme,  // Your dark theme
            themeMode: themeProvider.themeMode, // Controlled by ThemeProvider
            home: const HomePage(),
            //home: const AuthWrapper(),
            // HomePage and its descendants will be able to access both
            // ExpenseData and ThemeProvider using Provider.of or Consumer
          );
        },
      ),
    );
  }
}
