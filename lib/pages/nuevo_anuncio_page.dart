import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NuevoAnuncioScreen extends StatefulWidget {
  const NuevoAnuncioScreen({super.key});

  @override
  createState() => _NuevoAnuncioScreenState();
}

class _NuevoAnuncioScreenState extends State<NuevoAnuncioScreen> {
  final TextEditingController _anuncioController = TextEditingController();
  double _rapidezAnuncio = 30;
  Color _selectedColor = Colors.white;

  Future<void> guardarAnuncio() async {
    // Guarda el contexto antes de la operación asíncrona
    final scaffoldContext = ScaffoldMessenger.of(context);

    var response = await http.post(
      Uri.parse('${dotenv.env['URL']}/texto/add'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'texto': _anuncioController.text,
        'color': getColorName(_selectedColor),
        'velocidad': _rapidezAnuncio.toInt(),
      }),
    );

    if (!mounted) return; // Verifica si el widget sigue montado

    if (response.statusCode == 201) {
      // Si el anuncio se subió exitosamente (código de estado 201),
      // muestra un SnackBar indicando éxito.
      scaffoldContext.showSnackBar(
        const SnackBar(
          content: Text('Anuncio subido con éxito'),
          duration: Duration(seconds: 2), // Duración del SnackBar
        ),
      );
      Navigator.pop(context); // Cierra la pantalla actual
    } else {
      print('Error al subir anuncio: ${response.statusCode}');
      // Si ocurrió un error al subir el anuncio, muestra un mensaje de error.
      scaffoldContext.showSnackBar(
        const SnackBar(
          content: Text(
              'Error al subir el anuncio, verifique su conexión a internet'),
          duration: Duration(seconds: 2), // Duración del SnackBar
        ),
      );
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
              'Nuevo anuncio',
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
              'Rápidez del anuncio',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Slider(
              activeColor: Colors.blue,
              value: _rapidezAnuncio,
              min: 1,
              max: 30,
              divisions: 30,
              label: '${_rapidezAnuncio.round()} seg',
              onChanged: (value) {
                setState(() {
                  _rapidezAnuncio = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  guardarAnuncio();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blue, // Cambia el color del botón aquí
                ),
                child: const Text(
                  'Guardar anuncio',
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
