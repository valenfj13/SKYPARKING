import 'package:flutter/material.dart';

class AccessLogsScreen extends StatefulWidget {
  @override
  _AccessLogsScreenState createState() => _AccessLogsScreenState();
}

class _AccessLogsScreenState extends State<AccessLogsScreen> {
  // Lista local de accesos
  List<Map<String, dynamic>> accessLogs = [
    {
      'name': 'Valentina Franco Jaramillo',
      'placa': 'JQM187',
      'aparque': 'A1',
      'fecha_ingreso': '2024-11-18 10:30:00'
    },
    {
      'name': 'Daniel Garcia Jimenez',
      'placa': 'XYZ789',
      'aparque': 'B2',
      'fecha_ingreso': '2024-11-18 11:00:00'
    },
    {
      'name': 'Cristian Brandon Rodriguez',
      'placa': 'FOW676',
      'aparque': 'C3',
      'fecha_ingreso': '2024-11-18 12:45:00'
    },
    {
      'name': 'Ezequiel Lopez Perez',
      'placa': 'NKO562',
      'aparque': 'D2',
      'fecha_ingreso': '2024-11-18 13:15:00'
    },
  ];

  // Método para limpiar los registros
  void _clearLogs() {
    setState(() {
      accessLogs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logs de Acceso'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _clearLogs();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Todos los accesos han sido limpiados')),
              );
            },
          )
        ],
      ),
      body: accessLogs.isEmpty
          ? Center(
        child: Text(
          'No hay registros de acceso.',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: accessLogs.length,
        itemBuilder: (context, index) {
          final log = accessLogs[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: Icon(Icons.person, size: 40),
              title: Text(
                log['name'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Placa: ${log['placa']}'),
                  Text('Aparcamiento: ${log['aparque']}'),
                  Text('Fecha/Hora: ${log['fecha_ingreso']}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
