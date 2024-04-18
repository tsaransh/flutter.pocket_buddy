class ExpenseRoom {
  const ExpenseRoom(
      {required this.id,
      required this.title,
      required this.createdDate,
      required this.createdBy});

  final String id;
  final String title;
  final DateTime createdDate;
  final String createdBy;
}
