import 'package:hive/hive.dart';

part 'anuncio.g.dart';

@HiveType(typeId: 0)
class Anuncio extends HiveObject {
  @HiveField(0)
  final String titulo;

  @HiveField(1)
  final List<int> colors;

  Anuncio(this.titulo, this.colors);
}