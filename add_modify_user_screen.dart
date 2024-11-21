import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddModifyUserScreen extends StatefulWidget {
  @override
  _AddModifyUserScreenState createState() => _AddModifyUserScreenState();
}

class _AddModifyUserScreenState extends State<AddModifyUserScreen> {
  File? _image;
  final _nameController = TextEditingController();

  // Función para seleccionar una imagen de la galería o cámara
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  // Función para enviar la imagen y el nombre al servidor Flask
  Future<void> _uploadImage() async {
    if (_image == null || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona una imagen y añade un nombre')),
      );
      return;
    }

    String uploadUrl = 'http://192.168.1.15:5000/addUser';
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.fields['name'] = _nameController.text;

    // Subir la imagen como archivo
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario añadido correctamente')),
      );
      setState(() {
        _image = null;
        _nameController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al añadir el usuario')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir/Modificar Usuario'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre del usuario'),
            ),
            SizedBox(height: 20),
            _image == null
                ? Text('No se ha seleccionado ninguna imagen')
                : Image.file(_image!, height: 200),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: Text('Seleccionar de la galería'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: Text('Tomar una foto'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Añadir/Modificar Usuario'),
            ),
          ],
        ),
      ),
    );
  }
}
