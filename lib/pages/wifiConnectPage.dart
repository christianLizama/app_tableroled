import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';

class WifiConnectPage extends StatefulWidget {
  const WifiConnectPage({super.key});

  @override
  _WifiConnectPageState createState() => _WifiConnectPageState();
}

class _WifiConnectPageState extends State<WifiConnectPage> {
  final TextEditingController _ssidController =
      TextEditingController(text: 'nodemcu');
  final TextEditingController _passwordController =
      TextEditingController(text: '12345678');

  Future<void> connect() async {
    String ssid = _ssidController.text;
    String password = _passwordController.text;

    bool isWifiEnabled = await WiFiForIoTPlugin.isEnabled();
    if (!isWifiEnabled) {
      await WiFiForIoTPlugin.setEnabled(true);
    }

    bool isConnected = await WiFiForIoTPlugin.connect(
      ssid,
      password: password,
      security: NetworkSecurity.WPA,
    );

    if (isConnected) {
      print('Conectado a $ssid');
      //enviar a vista wifiArduinoPage
      Navigator.pushNamed(context, '/wifiArduino');
    } else {
      print('No se pudo conectar a $ssid');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conectar a Wi-Fi'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _ssidController,
              decoration: const InputDecoration(
                labelText: 'SSID',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
              ),
            ),
            ElevatedButton(
              onPressed: connect,
              child: const Text('Conectar'),
            ),
          ],
        ),
      ),
    );
  }
}
