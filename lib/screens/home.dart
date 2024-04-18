import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocketbuddy/model/base_url.dart';
import 'package:pocketbuddy/model/expense.dart';
import 'package:pocketbuddy/screens/user_profile.dart';
import 'package:pocketbuddy/widgets/drawer.dart';
import 'package:pocketbuddy/widgets/user_show_expense.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum SampleItem {
  profile,
  download,
  logout,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _expenseReasonController = TextEditingController();
  final _expenseAmountController = TextEditingController();

  bool isLoading = false;

  final BaseUrl urls = BaseUrl();

  final List<Expense> _expenseList = [];
  double allTimeTotalExp = 0.00;
  double monthTotalExp = 0.00;

  @override
  void initState() {
    super.initState();
    _fetchExpenseFromDB();
    fetchExpenseAmountTotal();
  }

  void refreshExpenseTotal() {
    fetchExpenseAmountTotal();
  }

  void fetchExpenseAmountTotal() async {
    Uri allTimeUrl = Uri.parse(
        "${urls.personalExpense}/alltimetotal?userUid=${FirebaseAuth.instance.currentUser!.uid}");

    Uri monthTotalUrl = Uri.parse("${urls.personalExpense}/total");

    try {
      final allTotalResponse = await http.get(allTimeUrl);

      final DateTime startDate =
          DateTime.now().subtract(const Duration(days: 30));

      final DateTime endDate = DateTime.now();

      final monthTotalResponse = await http.post(
        monthTotalUrl,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "id": FirebaseAuth.instance.currentUser!.uid,
          "startDate": startDate.toIso8601String(),
          "endDate": endDate.toIso8601String()
        }),
      );

      if (allTotalResponse.statusCode == 200 &&
          monthTotalResponse.statusCode == 200) {
        final value1 = json.decode(allTotalResponse.body);
        final value2 = json.decode(monthTotalResponse.body);

        setState(() {
          allTimeTotalExp = value1;
          monthTotalExp = value2;
        });
      } else {
        _showError("");
      }
    } catch (error) {
      print("error he bhai ki ${error}");
      _showError(error);
    }
  }

  void _fetchExpenseFromDB() async {
    Uri url = Uri.parse(
        "${urls.personalExpense}/alltimestatement?userUid=${FirebaseAuth.instance.currentUser!.uid}");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> responseList = json.decode(response.body);

        for (int i = 0; i < responseList.length; i++) {
          Map<String, dynamic> map = responseList[i];
          Expense expense = Expense.value(
              id: map['id'],
              expenseTitle: map['expenseTitle'],
              expenseAmount: map['expenseAmount'],
              expenseDate: DateTime.parse(map['date']),
              userUid: map['userUid']);
          _expenseList.add(expense);
        }
        setState(() {});
      }
    } catch (error) {
      print("error aa rha he -> ${error}");
      _showError(error);
    }
  }

  void _addExpense() async {
    setState(() {
      isLoading = !isLoading;
    });

    Expense expense = Expense(
      _expenseReasonController.text,
      double.parse(_expenseAmountController.text),
      FirebaseAuth.instance.currentUser!.uid,
      DateTime.now(),
    );

    final url = Uri.parse("${urls.personalExpense}/add");

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
        Map<String, dynamic> map = json.decode(response.body);

        Expense expense = Expense.value(
            id: map['id'],
            expenseTitle: map['expenseTitle'],
            expenseAmount: map['expenseAmount'],
            expenseDate: DateTime.parse(map['date']),
            userUid: map['userUid']);

        _expenseList.add(expense);
        fetchExpenseAmountTotal();

        Navigator.of(context).pop();
        setState(() {
          isLoading = !isLoading;
        });
        _expenseAmountController.text = "";
        _expenseReasonController.text = "";
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("error aa rha he -> ${error}");
      _showError(error);
    }
  }

  void _showError(Object error) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            content: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Something went wrong, Please try again later!"),
                  const SizedBox(height: 8),
                  const SizedBox(height: 16),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Okay"))
                ],
              ),
            ),
          );
        });
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  if (!isLoading) ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal),
                      onPressed: _addExpense,
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Add',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ]
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => const UserProfile(),
                      ),
                    );
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
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Total Expense',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '₹ $allTimeTotalExp',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Last Month',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '₹ $monthTotalExp',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _expenseList.isNotEmpty
                ? ShowUserExpenseTable(
                    expenses: _expenseList,
                    refreshExpenseTotal: refreshExpenseTotal,
                  )
                : const Center(
                    child: Text("Please add something to see 😊"),
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
}
