import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AddAnuncioPage extends StatefulWidget {
  const AddAnuncioPage({super.key});

  @override
  createState() => _AddAnuncioPageState();
}

class _AddAnuncioPageState extends State<AddAnuncioPage> {
  final TextEditingController _controller = TextEditingController();
  Color _currentColor = Colors.black;

  Future<void> guardarAnuncio() async {
    var response = await http.post(
      Uri.parse('${dotenv.env['URL']}/texto/add'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'texto': _controller.text,
        'color': getColorName(_currentColor),
      }),
    );

    print('Status code: ${response.statusCode}');
    print('Response: $response');

    if (response.statusCode == 201) {
      print('Anuncio subido con éxito');
      Navigator.pop(context);
    } else {
      print('Error al subir el anuncio');
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
        title: const Text('Añadir nuevo anuncio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Introduce tu anuncio aquí',
              ),
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
            ElevatedButton(
              child: const Text('Guardar anuncio'),
              onPressed: guardarAnuncio,
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
