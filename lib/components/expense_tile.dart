import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

// ignore: must_be_immutable
class ExpenseTile extends StatelessWidget {
  const ExpenseTile(
      {super.key,
      required this.name,
      required this.amount,
      required this.dateTime,
      required this.deleteTapped,
      this.editTapped});

  final void Function(BuildContext)? deleteTapped;
  final void Function(BuildContext)? editTapped;
  final String amount;
  final DateTime dateTime;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(motion: const StretchMotion(), children: [
        // settings
        SlidableAction(
          onPressed: editTapped,
          icon: Icons.settings,
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),

        //delete button
        SlidableAction(
          onPressed: deleteTapped,
          icon: Icons.delete,
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ]),
      child: ListTile(
        title: Text(name),
        subtitle: Text('${dateTime.day}/${dateTime.month}/${dateTime.year}/'),
        trailing: Text('Ksh $amount'),
      ),
    );
  }
}
