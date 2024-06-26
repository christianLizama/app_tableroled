import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:tablero_led/pages/addAnuncioPage.dart';
import 'package:tablero_led/pages/misAnuncios_page.dart';
import 'package:tablero_led/pages/page_404.dart';
import 'package:tablero_led/pages/wifiConnectPage.dart';
import 'package:tablero_led/pages/wifiArduinoPage.dart';
import 'pages/anuncios_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  await Hive.openBox('anunciosBox');

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});
  final _routes = {
    '/': (context) => const AnunciosPage(),
    '/misAnuncios': (context) => const MisAnunciosPage(),
    '/wifiConnect': (context) => const WifiConnectPage(),
    '/addAnuncio': (context) => const AddAnuncioPage(),
    '/wifiArduino': (context) => const WiFiScreen()
  };
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: _routes,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const Page404(),
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
