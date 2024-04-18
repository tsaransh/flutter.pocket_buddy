import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocketbuddy/model/base_url.dart';
import 'package:pocketbuddy/model/expense.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbuddy/model/log.dart';
import 'package:pocketbuddy/widgets/expense_detail.dart';

class ShowUserExpenseTable extends StatefulWidget {
  const ShowUserExpenseTable({
    super.key,
    required this.expenses,
    required this.refreshExpenseTotal,
    required this.refershExpenseList,
  });

  final List<Expense> expenses;
  final Function(int n) refreshExpenseTotal;
  final Function() refershExpenseList;

  @override
  State<StatefulWidget> createState() => _ShowUserExpenseTableState();
}

class _ShowUserExpenseTableState extends State<ShowUserExpenseTable> {
  final BaseUrl urls = BaseUrl();

  Future<void> _deleteExpense(Expense expense, int index) async {
    final Uri url =
        Uri.parse("${urls.personalExpense}/delete?id=${expense.id}");
    final bool shouldDelete = await _showWarning(expense.expenseTitle);

    if (shouldDelete) {
      try {
        final response = await http.delete(url);

        if (response.statusCode == 200) {
          setState(() {
            widget.expenses.remove(expense);
          });
        }
      } catch (error) {
        Logger.log(error.toString());
      }
    }
  }

  Future<bool> _showWarning(String expenseTitle) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Warning'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Are you sure you want to delete $expenseTitle?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                  widget.refreshExpenseTotal(widget.expenses.length - 1);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 10,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: widget.expenses.isEmpty
            ? const Center(child: Text("Oops no data found!"))
            : ListView.builder(
                itemCount: widget.expenses.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildHeaderRow();
                  }
                  final expense = widget.expenses[index - 1];
                  return Dismissible(
                    key: Key(expense.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      color: Colors.red,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                    onDismissed: (direction) {
                      _deleteExpense(expense, index - 1);
                    },
                    child: GestureDetector(
                        onTap: () async {
                          final bool response = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => ExpenseDetails(
                                expense: expense,
                              ),
                            ),
                          );
                          if (response) {
                            setState(() {
                              widget.refershExpenseList();
                            });
                          }
                        },
                        child: _buildExpenseRow(expense)),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(1),
      },
      border: TableBorder.all(),
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
          ),
          children: [
            _buildHeaderCell('Date'),
            _buildHeaderCell('Title'),
            _buildHeaderCell('Amount'),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildExpenseRow(Expense expense) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(1),
      },
      border: TableBorder.all(),
      children: [
        TableRow(
          children: [
            _buildCell(DateFormat('dd-MM-yyyy').format(expense.expenseDate)),
            _buildCell(expense.expenseTitle),
            _buildCell('₹ ${expense.expenseAmount}'),
          ],
        ),
      ],
    );
  }

  Widget _buildCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }
}
