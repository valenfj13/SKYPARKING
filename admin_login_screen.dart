import 'package:flutter/material.dart';
import 'admin_panel_screen.dart';  // Pantalla del panel de administrador

class AdminLoginScreen extends StatefulWidget {
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Aquí puedes agregar la lógica de autenticación
    if (username == "admin" && password == "admin123") {
      // Si el login es exitoso, navega al panel de administración
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminPanelScreen()),
      );
    } else {
      // Si falla, muestra un mensaje de error
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Login Fallido'),
            content: Text('Usuario o contraseña incorrectos'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login de Administrador'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Iniciar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
