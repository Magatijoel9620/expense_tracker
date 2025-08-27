// models/expense_item.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp & DocumentSnapshot

class ExpenseItem {
  final String? id; // Firestore document ID, nullable for new items
  final String name;
  final String amount;
  final DateTime dateTime;

  ExpenseItem({
    this.id,
    required this.name,
    required this.amount,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }

  // Create an ExpenseItem from a Firestore document snapshot
  factory ExpenseItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!; // Get data from the snapshot
    return ExpenseItem(
      id: doc.id, // The document's ID
      name: data['name'] as String? ?? '', // Handle potential null with ??
      amount: data['amount'] as String? ?? '0.00', // Handle potential null
      dateTime: (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(), // Handle potential null and convert
    );
  }

// If you still need a fromMap for other purposes (e.g., Hive), define it clearly.
// For Firestore, fromFirestore is generally preferred.
// Example of a simple fromMap if you were getting a Map directly:

  factory ExpenseItem.fromMap(String id, Map<String, dynamic> map) {
    return ExpenseItem(
      id: id,
      name: map['name'] as String,
      amount: map['amount'] as String,
      dateTime: (map['dateTime'] as Timestamp).toDate(), // Assumes dateTime is always a Timestamp in the map
    );
  }

}