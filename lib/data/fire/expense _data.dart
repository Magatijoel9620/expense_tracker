// data/expense_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:flutter/material.dart';
import 'package:expense_tracker/data/fire/expense_item.dart';
import 'package:expense_tracker/datetime/date_time_helper.dart';

class ExpenseData with ChangeNotifier {
  // list of ALL expenses
  List<ExpenseItem> overallExpenseList = [];

  // get expense list
  List<ExpenseItem> getAllExpenseList() {
    return overallExpenseList;
  }

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Get FirebaseAuth instance

  // Current user ID - this needs to be set when the user logs in
  // Or better, make methods require the UID or get it directly.
  String? get _userId => _auth.currentUser?.uid;

  // prepare data to display from firestore
  Future<void> prepareData() async {
    if (_userId == null) {
      print("User not logged in, cannot prepare data.");
      overallExpenseList = []; // Clear list if no user
      notifyListeners();
      return;
    }

    // Clear existing list before fetching
    overallExpenseList = [];

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users') // Top-level 'users' collection
          .doc(_userId)        // Document for the current user
          .collection('expenses') // Subcollection 'expenses'
          .orderBy('dateTime', descending: true) // Optional: order by date
          .get();

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Assuming your ExpenseItem can be created from a Map
        // and your Firestore documents have 'id', 'name', 'amount', 'dateTime'
        ExpenseItem item = ExpenseItem.fromMap(doc.id, data);
        overallExpenseList.add(item);
      }
      print("Data prepared for user: $_userId, count: ${overallExpenseList.length}");
    } catch (e) {
      print("Error preparing data from Firestore: $e");
      // Handle error appropriately
    }
    notifyListeners();
  }


  // add new expense to Firestore
  Future<void> addNewExpense(ExpenseItem newExpense) async {
    if (_userId == null) {
      print("User not logged in, cannot add expense.");
      return;
    }
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('expenses')
          .add(newExpense.toMap()); // Assuming ExpenseItem has a toMap() method
      // After adding, refresh data or add locally and notify
      await prepareData(); // Simplest way to refresh, or add locally for responsiveness
    } catch (e) {
      print("Error adding new expense to Firestore: $e");
    }
  }

  // delete expense from Firestore
  Future<void> deleteExpense(ExpenseItem expense) async {
    if (_userId == null || expense.id == null) { // Assuming ExpenseItem has an 'id' field for Firestore doc ID
      print("User not logged in or expense ID missing, cannot delete expense.");
      return;
    }
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('expenses')
          .doc(expense.id) // Use the document ID of the expense
          .delete();
      await prepareData(); // Refresh data
    } catch (e) {
      print("Error deleting expense from Firestore: $e");
    }
  }

  // update expense in Firestore
  Future<void> updateExpense(ExpenseItem updatedExpense, ExpenseItem originalExpense) async {
    if (_userId == null || originalExpense.id == null) {
      print("User not logged in or original expense ID missing, cannot update expense.");
      return;
    }
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('expenses')
          .doc(originalExpense.id) // Use the ID of the expense to update
          .update(updatedExpense.toMap()); // Update with new data
      await prepareData(); // Refresh data
    } catch (e) {
      print("Error updating expense in Firestore: $e");
    }
  }
  void clearAllExpensesLocally() {
    overallExpenseList = [];
    notifyListeners();
    print("Local expenses cleared on logout.");
  }

  // get weekday (mon, tues, etc) from a DateTime object
  String getDayName(DateTime dateTime) {
    // ... (your existing method) ...
    switch (dateTime.weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }


  // get the date for the start of the week (sunday)
  DateTime startOfWeekDate() {
    // ... (your existing method) ...
    DateTime? startOfWeek;
    DateTime today = DateTime.now();
    for (int i = 0; i < 7; i++) {
      if (getDayName(today.subtract(Duration(days: i))) == 'Sun') {
        startOfWeek = today.subtract(Duration(days: i));
      }
    }
    return startOfWeek!;
  }


  // convert overall list of expenses into a daily expense summary
  Map<String, double> calculateDailyExpenseSummary() {
    Map<String, double> dailyExpenseSummary = {
      // date (yyyymmdd) : amountTotalForDay
    };

    for (var expense in overallExpenseList) {
      String date = convertDateTimeToString(expense.dateTime);
      double amount = double.parse(expense.amount);

      if (dailyExpenseSummary.containsKey(date)) {
        double currentAmount = dailyExpenseSummary[date]!;
        currentAmount += amount;
        dailyExpenseSummary[date] = currentAmount;
      } else {
        dailyExpenseSummary.addAll({date: amount});
      }
    }
    return dailyExpenseSummary;
  }
}

// You'll need to add toMap() and fromMap() to your ExpenseItem model
// Example for ExpenseItem model:
// class ExpenseItem {
//   final String? id; // To store Firestore document ID
//   final String name;
//   final String amount;
//   final DateTime dateTime;

//   ExpenseItem({this.id, required this.name, required this.amount, required this.dateTime});

//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'amount': amount,
//       'dateTime': Timestamp.fromDate(dateTime), // Store as Firestore Timestamp
//     };
//   }

//   factory ExpenseItem.fromMap(String id, Map<String, dynamic> map) {
//     return ExpenseItem(
//       id: id,
//       name: map['name'] as String,
//       amount: map['amount'] as String,
//       dateTime: (map['dateTime'] as Timestamp).toDate(), // Convert Timestamp to DateTime
//     );
//   }
// }
