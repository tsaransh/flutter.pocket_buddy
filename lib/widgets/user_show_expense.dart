import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocketbuddy/model/base_url.dart';
import 'package:pocketbuddy/model/expense.dart';
import 'package:http/http.dart' as http;

class ShowUserExpenseTable extends StatefulWidget {
  const ShowUserExpenseTable(
      {super.key, required this.expenses, required this.refreshExpenseTotal});

  final List<Expense> expenses;
  final VoidCallback refreshExpenseTotal;
  @override
  State<StatefulWidget> createState() {
    return _ShowUserExpenseTableState();
  }
}

class _ShowUserExpenseTableState extends State<ShowUserExpenseTable> {
  final BaseUrl urls = BaseUrl();
  bool _performDeleteOperation = false;

  Future<void> _deleteExpense(Expense expense, int index) async {
    final Uri url =
        Uri.parse("${urls.personalExpense}/delete?id=${expense.id}");
    final bool shouldDelete = await _showWarning(expense.expenseTitle);

    if (shouldDelete) {
      try {
        final response = await http.delete(url);

        if (response.statusCode == 200) {
          setState(() {
            widget.refreshExpenseTotal;
            widget.expenses.remove(expense);
          });
        }
      } catch (error) {
        print(error);
      }
    } else {
      setState(() {
        // do this for refelect the changes
      });
    }
  }

  Future<bool> _showWarning(String expenseTitle) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Warning'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Are you sure you want to delete $expenseTitle'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Delete'),
                  )
                ],
              )
            ],
          ),
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 10,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView.builder(
          itemCount: widget.expenses.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildHeaderRow();
            }
            final expense = widget.expenses[index - 1];
            return Dismissible(
              key: UniqueKey(), // Use UniqueKey instead of expense.id
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
              child: _buildExpenseRow(expense),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1), // Adjust the width of Date column
        1: FlexColumnWidth(3), // Adjust the width of Title column
        2: FlexColumnWidth(1), // Adjust the width of Amount column
      },
      border: TableBorder.all(),
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
          ),
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Date',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Title',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Amount',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpenseRow(Expense expense) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1), // Adjust the width of Date column
        1: FlexColumnWidth(3), // Adjust the width of Title column
        2: FlexColumnWidth(1), // Adjust the width of Amount column
      },
      border: TableBorder.all(),
      children: [
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                DateFormat('dd-MM-yyyy').format(expense.expenseDate),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                expense.expenseTitle,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '₹ ${expense.expenseAmount}', // Assuming `amount` is a property in Expense class
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
