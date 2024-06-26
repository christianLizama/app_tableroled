import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class EditarAnuncioScreen extends StatefulWidget {
  final String texto;
  final String color;
  final String id; // Asume que cada anuncio tiene un ID único para identificarlo

  const EditarAnuncioScreen({
    required this.texto,
    required this.color,
    required this.id,
    Key? key,
  }) : super(key: key);

  @override
  createState() => _EditarAnuncioScreenState();
}

class _EditarAnuncioScreenState extends State<EditarAnuncioScreen> {
  late TextEditingController _anuncioController;
  Color _selectedColor = Colors.white;
  double _tiempoAnuncio = 24.0;

  @override
  void initState() {
    super.initState();
    _anuncioController = TextEditingController(text: widget.texto);
    _selectedColor = getColorFromName(widget.color);
  }

  Future<void> actualizarAnuncio() async {
    var response = await http.put(
      Uri.parse('${dotenv.env['URL']}/texto/update/${widget.id}'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'texto': _anuncioController.text,
        'color': getColorName(_selectedColor),
      }),
    );

    print('Status code: ${response.statusCode}');
    print('Response: $response');

    if (response.statusCode == 200) {
      print('Anuncio actualizado con éxito');
      Navigator.pop(context);
    } else {
      print('Error al actualizar el anuncio');
    }
  }

  void _selectColor(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  Color getColorFromName(String colorName) {
    switch (colorName) {
      case 'blanco':
        return Colors.white;
      case 'rojo':
        return Colors.red;
      case 'verde':
        return Colors.green;
      case 'azul':
        return Colors.blue;
      case 'amarillo':
        return Colors.yellow;
      default:
        return Colors.white; // Default color if no match is found
    }
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
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Editar anuncio',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _anuncioController,
              decoration: const InputDecoration(
                hintText: 'Ingrese texto del anuncio',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            const Text(
              'Color',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildColorCircle(Colors.white),
                _buildColorCircle(Colors.red),
                _buildColorCircle(Colors.green),
                _buildColorCircle(Colors.yellow),
                _buildColorCircle(Colors.blue),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Tiempo de anuncio',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Slider(
              activeColor: Colors.blue,
              value: _tiempoAnuncio,
              min: 0,
              max: 60,
              divisions: 60,
              label: '${_tiempoAnuncio.round()} seg',
              onChanged: (value) {
                setState(() {
                  _tiempoAnuncio = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  print('Texto: ${_anuncioController.text}');
                  print('Color: ${getColorName(_selectedColor)}');
                  actualizarAnuncio();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'Guardar cambios',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 3),
              blurRadius: 5,
            ),
          ],
        ),
        child: CircleAvatar(
          backgroundColor: color,
          radius: 20,
          child: _selectedColor == color
              ? const Icon(Icons.check, color: Colors.black)
              : null,
        ),
      ),
    );
  }
}
