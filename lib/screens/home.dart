import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocketbuddy/model/base_url.dart';
import 'package:pocketbuddy/model/expense.dart';
import 'package:pocketbuddy/model/log.dart';
import 'package:pocketbuddy/screens/user_profile.dart';
import 'package:pocketbuddy/widgets/drawer.dart';
import 'package:pocketbuddy/widgets/user_show_expense.dart';
import 'package:http/http.dart' as http;

enum SampleItem {
  profile,
  download,
  logout,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _expenseReasonController =
      TextEditingController();
  final TextEditingController _expenseAmountController =
      TextEditingController();

  bool _isLoading = false;

  final BaseUrl _urls = BaseUrl();

  final List<Expense> _expenseList = [];
  double _allTimeTotalExp = 0.00;
  double _monthTotalExp = 0.00;

  @override
  void initState() {
    super.initState();
    _fetchExpenseFromDB();
    _fetchExpenseAmountTotal();
  }

  Future<void> refershExpenseTotalsAmounts(int n) async {
    if (n != 0) {
      await _fetchExpenseAmountTotal();
    } else {
      setState(() {
        _allTimeTotalExp = 0.00;
        _monthTotalExp = 0.00;
      });
    }
  }

  Future<void> _fetchExpenseAmountTotal() async {
    try {
      final allTimeResponse = await http.get(Uri.parse(
          "${_urls.personalExpense}/alltimetotal?userUid=${FirebaseAuth.instance.currentUser!.uid}"));
      final monthTotalResponse = await http.post(
        Uri.parse("${_urls.personalExpense}/total"),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: json.encode({
          "id": FirebaseAuth.instance.currentUser!.uid,
          "startDate": DateTime.now()
              .subtract(const Duration(days: 30))
              .toIso8601String(),
          "endDate": DateTime.now().toIso8601String(),
        }),
      );

      if (allTimeResponse.statusCode == 200 &&
          monthTotalResponse.statusCode == 200) {
        final allTimeTotal = json.decode(allTimeResponse.body);
        final monthTotal = json.decode(monthTotalResponse.body);

        setState(() {
          _allTimeTotalExp = allTimeTotal;
          _monthTotalExp = monthTotal;
        });
      }
    } catch (error) {
      Logger.log(error.toString());
      _showError();
    }
  }

  void _fetchExpenseFromDB() async {
    try {
      final response = await http.get(Uri.parse(
          "${_urls.personalExpense}/alltimestatement?userUid=${FirebaseAuth.instance.currentUser!.uid}"));

      if (response.statusCode == 200) {
        final List<dynamic> responseList = json.decode(response.body);

        for (final map in responseList) {
          final expense = Expense.value(
            id: map['id'],
            expenseTitle: map['expenseTitle'],
            expenseAmount: map['expenseAmount'],
            expenseDate: DateTime.parse(map['date']),
            userUid: map['userUid'],
          );
          _expenseList.add(expense);
        }
        setState(() {});
      }
    } catch (error) {
      Logger.log(error.toString());
      _showError();
    }
  }

  void _addExpense() async {
    setState(() {
      _isLoading = true;
    });

    final expense = Expense(
      _expenseReasonController.text,
      double.parse(_expenseAmountController.text),
      FirebaseAuth.instance.currentUser!.uid,
      DateTime.now(),
    );

    final url = Uri.parse("${_urls.personalExpense}/add");

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "id": expense.id,
          "expenseTitle": expense.expenseTitle,
          "expenseAmount": expense.expenseAmount,
          "userUid": expense.userUid,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> map = json.decode(response.body);

        final newExpense = Expense.value(
          id: map['id'],
          expenseTitle: map['expenseTitle'],
          expenseAmount: map['expenseAmount'],
          expenseDate: DateTime.parse(map['date']),
          userUid: map['userUid'],
        );

        _expenseList.add(newExpense);
        _fetchExpenseAmountTotal();

        Navigator.of(context).pop();
      }
    } catch (error) {
      Logger.log(error.toString());
      _showError();
    } finally {
      setState(() {
        _isLoading = false;
      });
      _expenseAmountController.text = '';
      _expenseReasonController.text = '';
    }
  }

  void _showError() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Something went wrong, Please try again later!"),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Okay"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddExpenseForm() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _expenseReasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason of Expense',
                  prefix: Icon(Icons.data_array_rounded),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _expenseAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefix: Text('₹'),
                        labelText: 'Enter Amount',
                      ),
                    ),
                  ),
                  if (!_isLoading)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal),
                      onPressed: _addExpense,
                      icon: const Icon(Icons.add),
                      label: const Text('Add',
                          style: TextStyle(color: Colors.white)),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(
        title: const Text('Pocket Buddy'),
        actions: [
          PopupMenuButton<SampleItem>(
            icon: const Icon(Icons.person),
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<SampleItem>>[
                PopupMenuItem<SampleItem>(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => const UserProfile()));
                  },
                  mouseCursor: MouseCursor.defer,
                  value: SampleItem.profile,
                  child: const ListTile(
                    leading: Icon(Icons.person_3),
                    title: Text('Profile'),
                  ),
                ),
                PopupMenuItem(
                  onTap: () {},
                  child: const ListTile(
                    leading: Icon(Icons.download_rounded),
                    title: Text('Download Statement'),
                  ),
                ),
                PopupMenuItem<SampleItem>(
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                  },
                  value: SampleItem.logout,
                  child: const ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                  ),
                ),
                PopupMenuItem(
                  onTap: () {},
                  child: const ListTile(
                    leading: Icon(Icons.app_settings_alt),
                    title: Text('About App'),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildTotalExpenseCard(
                      'Total Expense', _allTimeTotalExp, Colors.green),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTotalExpenseCard(
                      'This Month', _monthTotalExp, Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ShowUserExpenseTable(
              expenses: _expenseList,
              refreshExpenseTotal: (int n) {
                refershExpenseTotalsAmounts(n);
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: _showAddExpenseForm,
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTotalExpenseCard(String title, double amount, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              '₹ $amount',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
