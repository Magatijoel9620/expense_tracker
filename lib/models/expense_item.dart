// import 'package:isar/isar.dart';
// // this line is needed to generate isar file
// //run cmd in terminal: dart run build_runner build
// part 'expense.g.dart';

//@Collection()
class ExpenseItem {
  //Id id = Isar.autoIncrement; //0,1,2,3...
  final String name;
  final String amount;
  final DateTime dateTime;

  ExpenseItem({
    required this.name,
    required this.amount,
    required this.dateTime,
  });
}
