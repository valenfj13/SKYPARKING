import 'package:flutter/material.dart';
import 'add_modify_user_screen.dart';  // Importar la pantalla de agregar/modificar usuario
import 'AccessLogsScreen.dart'; // Nueva pantalla para ver los logs
class AdminPanelScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de Administración'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Bienvenido al Panel de Administración',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navegar a la pantalla de añadir/modificar usuarios
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddModifyUserScreen()),
                );
              },
              child: Text('Añadir/Modificar Usuario'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccessLogsScreen()),
                );

                // Aquí puedes añadir más funcionalidades como ver logs
              },
              child: Text('Ver Logs de Acceso'),
            ),
          ],
        ),
      ),
    );
  }
}
