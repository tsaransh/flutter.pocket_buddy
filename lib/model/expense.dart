// ignore_for_file: file_names

import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class Expense {
  Expense(this.expenseTitle, this.expenseAmount, this.userUid, this.expenseDate)
      : id = uuid.v4();
  final String id;
  final String expenseTitle;
  final double expenseAmount;
  final DateTime expenseDate;
  final String userUid;

  Expense.value(
      {required this.id,
      required this.expenseTitle,
      required this.expenseAmount,
      required this.expenseDate,
      required this.userUid});
}
