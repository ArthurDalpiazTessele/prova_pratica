import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartPage extends StatelessWidget {
  final List<Map<String, dynamic>> expenses;

  ChartPage({required this.expenses});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> grouped = {};

    for (var e in expenses) {
      final desc = e['descricao'];
      final valor = e['valor'] as double;
      grouped[desc] = (grouped[desc] ?? 0) + valor;
    }

    final total = grouped.values.fold(0.0, (sum, v) => sum + v);
    final colors = [
      Colors.teal,
      Colors.orange,
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.red,
      Colors.brown,
      Colors.indigo,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Gráfico de Despesas'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: grouped.isEmpty
            ? Text('Nenhuma despesa para exibir.')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: grouped.entries.mapIndexed((index, entry) {
                          final valor = entry.value;
                          return PieChartSectionData(
                            color: colors[index % colors.length],
                            value: valor,
                            title: '${entry.key}\nR\$ ${valor.toStringAsFixed(2)}',
                            radius: 80,
                            titleStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            titlePositionPercentageOffset: 0.6,
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Total: R\$ ${total.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}

// Extensão para mapIndexed
extension MapIndexed<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E item) f) {
    var i = 0;
    return map((e) => f(i++, e));
  }
}