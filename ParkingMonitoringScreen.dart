import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ParkingMonitoringScreen extends StatefulWidget {
  @override
  _ParkingMonitoringScreenState createState() =>
      _ParkingMonitoringScreenState();
}

class _ParkingMonitoringScreenState extends State<ParkingMonitoringScreen> {
  String _currentTime = '';
  final String streamUrl = 'http://192.168.1.20:5001/parkingStream'; // Cambia <SERVER_IP> por la IP del servidor Python

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  void _updateTime() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monitoreo del Aparcamiento'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Hora Actual: $_currentTime',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: Uri.parse(streamUrl)),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
