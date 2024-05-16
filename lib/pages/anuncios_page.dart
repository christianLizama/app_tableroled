import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/anuncio.dart';
import '../utils/network_utils.dart';
import 'dart:async';

class AnunciosPage extends StatefulWidget {
  const AnunciosPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AnunciosPageState();
  }
}

class _AnunciosPageState extends State<AnunciosPage> {
  final _messageController = TextEditingController();
  List<int> _colors = List.filled(16 * 32, 0xFF000000); // Inicializa la matriz de colores

  Color _currentColor = Colors.black;
  Timer? _timer;
  int _offset = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _pickColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecciona un color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _currentColor,
              onColorChanged: (color) {
                setState(() {
                  _currentColor = color;
                });
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _setPixel(int index, Color color) {
    setState(() {
      _colors[index] = color.value;
    });
  }

  void _drawText(String text) {
    _offset = text.length * 8; // Comienza desde el final del texto
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        _colors = List.filled(16 * 32, 0xFF000000);
        _drawMessage(text, _offset);
        _offset--;
        if (_offset < -32) { // Hasta que todo el texto haya pasado por completo
          _offset = text.length * 8;
        }
      });
    });
  }

  void _drawMessage(String message, int offset) {
    for (int i = 0; i < message.length; i++) {
      _drawCharacter(message[i], 32 - (i * 8 + offset), 4); // Ajuste para desplazamiento de derecha a izquierda
    }
  }

  void _drawCharacter(String char, int xOffset, int yOffset) {
    // Mapa de bits de una fuente simple de 8x8 para letras
    Map<String, List<int>> font = {
      'A': [0x30, 0x78, 0xCC, 0xCC, 0xFC, 0xCC, 0xCC, 0x00],
      'B': [0xFC, 0x66, 0x66, 0x7C, 0x66, 0x66, 0xFC, 0x00],
      'C': [0x3C, 0x66, 0xC0, 0xC0, 0xC0, 0x66, 0x3C, 0x00],
      'D': [0xF8, 0x6C, 0x66, 0x66, 0x66, 0x6C, 0xF8, 0x00],
      'E': [0xFE, 0x62, 0x68, 0x78, 0x68, 0x62, 0xFE, 0x00],
      'F': [0xFE, 0x62, 0x68, 0x78, 0x68, 0x60, 0xF0, 0x00],
      'G': [0x3C, 0x66, 0xC0, 0xDE, 0xC6, 0x66, 0x3C, 0x00],
      'H': [0xCC, 0xCC, 0xCC, 0xFC, 0xCC, 0xCC, 0xCC, 0x00],
      'I': [0x38, 0x18, 0x18, 0x18, 0x18, 0x18, 0x38, 0x00],
      'J': [0x1E, 0x0C, 0x0C, 0x0C, 0xCC, 0xCC, 0x78, 0x00],
      'K': [0xE6, 0x66, 0x6C, 0x78, 0x6C, 0x66, 0xE6, 0x00],
      'L': [0xF0, 0x60, 0x60, 0x60, 0x62, 0x66, 0xFE, 0x00],
      'M': [0xC6, 0xEE, 0xFE, 0xFE, 0xD6, 0xC6, 0xC6, 0x00],
      'N': [0xC6, 0xE6, 0xF6, 0xFE, 0xDE, 0xCE, 0xC6, 0x00],
      'O': [0x38, 0x6C, 0xC6, 0xC6, 0xC6, 0x6C, 0x38, 0x00],
      'P': [0xFC, 0x66, 0x66, 0x7C, 0x60, 0x60, 0xF0, 0x00],
      'Q': [0x38, 0x6C, 0xC6, 0xC6, 0xD6, 0x6C, 0x3E, 0x00],
      'R': [0xFC, 0x66, 0x66, 0x7C, 0x6C, 0x66, 0xE6, 0x00],
      'S': [0x7C, 0xC6, 0xC0, 0x7C, 0x06, 0xC6, 0x7C, 0x00],
      'T': [0xFE, 0xD6, 0x18, 0x18, 0x18, 0x18, 0x3C, 0x00],
      'U': [0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xFC, 0x00],
      'V': [0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0x78, 0x30, 0x00],
      'W': [0xC6, 0xC6, 0xC6, 0xD6, 0xFE, 0xEE, 0xC6, 0x00],
      'X': [0xC6, 0xC6, 0x6C, 0x38, 0x6C, 0xC6, 0xC6, 0x00],
      'Y': [0xCC, 0xCC, 0xCC, 0x78, 0x30, 0x30, 0x78, 0x00],
      'Z': [0xFE, 0xC6, 0x8C, 0x18, 0x32, 0x66, 0xFE, 0x00],
      ' ': [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
    };

    List<int> charBitmap = font[char] ?? font[' ']!;
    for (int y = 0; y < 8; y++) {
      int row = charBitmap[y];
      for (int x = 0; x < 8; x++) {
        if ((row & (0x80 >> x)) != 0) {
          int index = (y + yOffset) * 32 + (x + xOffset);
          if (index >= 0 && index < 16 * 32) {
            _setPixel(index, _currentColor);
          }
        }
      }
    }
  }

  Future<void> saveAnuncio() async {
    final message = _messageController.text;
    if (message.isEmpty) {
      return;
    }

    final anuncio = Anuncio(message, _colors);

    if (await hasInternetConnection()) {
      // Guardar en la base de datos remota
      // Aquí puedes implementar tu lógica para guardar en la base de datos remota
      print('Guardado en la base de datos remota');
    } else {
      // Guardar localmente en Hive
      var box = Hive.box('anunciosBox');
      await box.add(anuncio);
      print('Guardado localmente');
    }

    _messageController.clear();
    setState(() {
      _colors = List.filled(16 * 32, 0xFF000000);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardar Anuncios'),
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
            GestureDetector(
              onTap: () => _pickColor(context),
              child: Container(
                width: 50,
                height: 50,
                color: _currentColor,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 32,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.all(1),
                    color: Color(_colors[index]),
                  );
                },
                itemCount: 16 * 32,
              ),
            ),
            ElevatedButton(
              onPressed: () => _drawText(_messageController.text),
              child: const Text('Escribir'),
            ),
            ElevatedButton(
              onPressed: saveAnuncio,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
