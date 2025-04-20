import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_expense_page.dart';
import 'chart_page.dart';
import 'pdf_generator.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> expenses = [];

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('expenses');
    if (data != null) {
      setState(() {
        expenses = List<Map<String, dynamic>>.from(json.decode(data));
      });
    }
  }

  Future<void> saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('expenses', json.encode(expenses));
  }

  void addExpense(Map<String, dynamic> expense) {
    setState(() {
      expenses.add(expense);
    });
    saveExpenses();
  }

  void updateExpense(int index, Map<String, dynamic> updatedExpense) {
    setState(() {
      expenses[index] = updatedExpense;
    });
    saveExpenses();
  }

  void deleteExpense(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Excluir despesa?'),
        content: Text('Tem certeza que deseja excluir esta despesa?'),
        actions: [
          TextButton(child: Text('Cancelar'), onPressed: () => Navigator.pop(context, false)),
          TextButton(child: Text('Excluir'), onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        expenses.removeAt(index);
      });
      saveExpenses();
    }
  }

  double getTotal() {
    return expenses.fold(0.0, (sum, item) => sum + (item['valor'] as double));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Despesas'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.pie_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChartPage(expenses: expenses),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () {
              if (expenses.isNotEmpty) {
                PDFGenerator.generateAndPrint(expenses);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Nenhuma despesa para exportar.')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Total gasto: R\$ ${getTotal().toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: expenses.isEmpty
                ? Center(child: Text('Nenhuma despesa cadastrada.'))
                : ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final item = expenses[index];
                      return Card(
                        child: ListTile(
                          title: Text(item['descricao']),
                          subtitle: Text('R\$ ${item['valor'].toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.orange),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddExpensePage(expense: item),
                                    ),
                                  );
                                  if (result != null) {
                                    updateExpense(index, result);
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteExpense(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddExpensePage()),
          );
          if (result != null) {
            addExpense(result);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}