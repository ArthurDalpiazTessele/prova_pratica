import 'package:flutter/material.dart';

class AddExpensePage extends StatefulWidget {
  final Map<String, dynamic>? expense;

  AddExpensePage({this.expense});

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  String descricao = '';
  double valor = 0;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      descricao = widget.expense!['descricao'];
      valor = widget.expense!['valor'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Nova Despesa' : 'Editar Despesa'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: descricao,
                decoration: InputDecoration(labelText: 'Descrição'),
                onSaved: (value) => descricao = value ?? '',
                validator: (value) =>
                    value == null || value.isEmpty ? 'Preencha a descrição' : null,
              ),
              TextFormField(
                initialValue: valor != 0 ? valor.toString() : '',
                decoration: InputDecoration(labelText: 'Valor (R\$)'),
                keyboardType: TextInputType.number,
                onSaved: (value) =>
                    valor = double.tryParse(value ?? '0') ?? 0,
                validator: (value) =>
                    value == null || double.tryParse(value) == null
                        ? 'Digite um valor válido'
                        : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text(widget.expense == null ? 'Salvar' : 'Atualizar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.pop(context, {
                      'descricao': descricao,
                      'valor': valor,
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}