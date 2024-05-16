// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anuncio.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnuncioAdapter extends TypeAdapter<Anuncio> {
  @override
  final int typeId = 0;

  @override
  Anuncio read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Anuncio(
      fields[0] as String,
      (fields[1] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, Anuncio obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.titulo)
      ..writeByte(1)
      ..write(obj.colors);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnuncioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
