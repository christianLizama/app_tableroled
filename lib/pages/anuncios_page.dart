import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class AnunciosPage extends StatefulWidget {
  const AnunciosPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AnunciosPageState();
  }
}

class _AnunciosPageState extends State<AnunciosPage> {
  final _messageController = TextEditingController();
  String _response = "...";
  Color _currentColor = Colors.black;

  Future<void> _sendRequest(String message, String colorName) async {
    final url = Uri.parse('http://192.168.4.1/');
    //mandar message en mayusculas
    message = message.toUpperCase();
    // Construye el cuerpo de la solicitud
    String body = 'message=$message&color=$colorName';

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: body,
    );

    if (response.statusCode == 200) {
      setState(() {
        _response = response.body;
      });
    } else {
      setState(() {
        _response = "Error en la solicitud: ${response.statusCode}";
      });
    }
  }

  void _selectColor(Color color) {
    setState(() {
      _currentColor = color;
    });
  }

  String getColorName(Color color) {
    if (color == Colors.white) {
      return 'blanco';
    } else if (color == Colors.red) {
      return 'rojo';
    } else if (color == Colors.green) {
      return 'verde';
    } else if (color == Colors.blue) {
      return 'azul';
    } else if (color == Colors.yellow) {
      return 'amarillo';
    }
    // Si el color no coincide con ninguno de los colores definidos, devuelve 'blanco' por defecto
    return 'blanco';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mostrar Mensaje en Tablero LED'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const SizedBox(
              height: 120, // Set the height you want here
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Drawer Header'),
              ),
            ),
            ListTile(
              title: const Text('Mis anuncios'),
              onTap: () {
                // Update the state of the app
                // Then close the drawer
                Navigator.pushNamed(context, '/misAnuncios');
              },
            ),
            ListTile(
              title: const Text('Wifi'),
              onTap: () {
                // Update the state of the app
                // Then close the drawer
                Navigator.pushNamed(context, '/wifiConnect');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Mensaje'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildColorCircle(Colors.white),
                const SizedBox(width: 10),
                _buildColorCircle(Colors.red),
                const SizedBox(width: 10),
                _buildColorCircle(Colors.green),
                const SizedBox(width: 10),
                _buildColorCircle(Colors.blue),
                const SizedBox(width: 10),
                _buildColorCircle(Colors.yellow),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 20),
            Text(_response),
            ElevatedButton(
              onPressed: () => _sendRequest(
                  _messageController.text, getColorName(_currentColor)),
              child: const Text('Mostrar en tablero LED'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorCircle(Color color) {
    return GestureDetector(
      onTap: () => _selectColor(color),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _currentColor == color ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}
