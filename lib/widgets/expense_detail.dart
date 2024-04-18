import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pocketbuddy/model/base_url.dart';
import 'package:pocketbuddy/model/expense.dart';
import 'package:pocketbuddy/model/log.dart';

import 'package:http/http.dart' as http;

class ExpenseDetails extends StatefulWidget {
  const ExpenseDetails({super.key, required this.expense});

  final Expense expense;

  @override
  State<ExpenseDetails> createState() => _ExpenseDetailsState();
}

class _ExpenseDetailsState extends State<ExpenseDetails> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;

  BaseUrl urls = BaseUrl();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense.expenseTitle);
    _amountController =
        TextEditingController(text: widget.expense.expenseAmount.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDataRow('Expense ID', widget.expense.id),
              _buildDataRow(
                  'Expense Date', widget.expense.expenseDate.toIso8601String()),
              _buildEditableRow("Expense Title", _titleController),
              _buildEditableRow("Expense Amount", _amountController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Implement update functionality
                  _updateExpense();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateExpense() async {
    // Implement update logic here
    // For example, you can get the updated values from _titleController and _amountController
    final updatedTitle = _titleController.text;
    final updatedAmount = double.tryParse(_amountController.text) ?? 0.0;

    try {
      Uri url = Uri.parse("${urls.personalExpense}/update");
      final response = await http.post(url,
          headers: <String, String>{'content-Type': 'application/json'},
          body: json.encode({
            "id": widget.expense.id,
            "expenseTitle": updatedTitle,
            "expenseAmount": updatedAmount,
            "userUid": widget.expense.userUid
          }));

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      Logger.log(error.toString());
    } finally {
      _titleController.text = "";
      _amountController.text = "";
    }
  }

  Widget _buildDataRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableRow(String title, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.text,
            style: const TextStyle(fontSize: 16),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
