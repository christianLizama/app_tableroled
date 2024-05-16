import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MisAnunciosPage extends StatefulWidget {
  const MisAnunciosPage({super.key});

  @override
  _MisAnunciosPageState createState() => _MisAnunciosPageState();
}

class _MisAnunciosPageState extends State<MisAnunciosPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _anuncios = [];

  @override
  void initState() {
    super.initState();
    cargarAnuncios();
  }

  Future<void> cargarAnuncios() async {
    var get = await http.get(
      Uri.parse('http://192.168.1.94:3030/texto/getAll'),
    );
    List<dynamic> data = json.decode(get.body);
    setState(() {
      _anuncios.addAll(data.map((item) => item['texto'].toString()).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis anuncios'),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Introduce tu anuncio aquí',
            ),
          ),
          ElevatedButton(
            child: const Text('Guardar anuncio'),
            onPressed: () async {
              setState(() {
                _anuncios.add(_controller.text);
              });
              var get = await http.get(
                Uri.parse('http://192.168.1.94:3030/texto/getAll'),
              );
              print(get.body);
              var response = await http.post(
                Uri.parse('http://192.168.1.94:3030/texto/add'),
                headers: {"Content-Type": "application/json"},
                body: json.encode({'texto': _controller.text}),
              );

              print('Status code: ${response.statusCode}');
              print('Response: $response');

              if (response.statusCode == 201) {
                print('Anuncio subido con éxito');
              } else {
                print('Error al subir el anuncio');
              }

              _controller.clear();
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _anuncios.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_anuncios[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
