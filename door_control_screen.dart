import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ParkingMonitoringScreen.dart';

class DoorControlScreen extends StatefulWidget {
  @override
  _DoorControlScreenState createState() => _DoorControlScreenState();
}

class _DoorControlScreenState extends State<DoorControlScreen> {
  String _doorStatus = 'Closed';
  String _welcomeMessage = '';
  Map<String, dynamic>? _userData; // Datos del usuario reconocido
  bool _isLoading = false;
  final String serverUrl = 'http://10.1.3.175:5001';

  Future<void> _startFaceRecognition() async {
    setState(() {
      _isLoading = true;
      _welcomeMessage = '';
      _userData = null;
    });
    try {
      final response = await http.post(Uri.parse('$serverUrl/startFaceRecognition'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          if (data['status'] == 'Opened') {
            _doorStatus = 'Opened';
            _welcomeMessage = '¡Bienvenido, ${data['data']['name']}!';
            _userData = data['data'];
          } else {
            _doorStatus = 'Face not recognized!';
            _welcomeMessage = '';
          }
        });
      } else {
        print('Error al iniciar el reconocimiento facial: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _closeDoor() {
    setState(() {
      _doorStatus = 'Closed';
      _welcomeMessage = '';
      _userData = null; // Limpia los datos del usuario
    });
    print("Puerta cerrada.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Control de Puerta'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Door is $_doorStatus',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Column(
              children: [
                if (_welcomeMessage.isNotEmpty)
                  Text(
                    _welcomeMessage,
                    style: TextStyle(fontSize: 20, color: Colors.green),
                  ),
                if (_userData != null) ...[
                  SizedBox(height: 20),
                  Text("Nombre: ${_userData!['name']}", style: TextStyle(fontSize: 18)),
                  Text("Placa: ${_userData!['placa']}", style: TextStyle(fontSize: 18)),
                  Text("Aparcamiento: ${_userData!['aparque']}", style: TextStyle(fontSize: 18)),
                  Text("Hora de Ingreso: ${_userData!['fecha_ingreso']}", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _closeDoor,
                    child: Text('Cerrar Puerta'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ParkingMonitoringScreen(),
                        ),
                      );
                    },
                    child: Text('Ir al Monitoreo del Aparcamiento'),
                  ),
                ],
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _startFaceRecognition,
                  child: Text('Iniciar Reconocimiento Facial'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
