// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 0;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      soundEnabled: fields[0] as bool,
      hapticEnabled: fields[1] as bool,
      hapticIntensityIndex: fields[2] as int,
      decimalPlaces: fields[3] as int,
      useGroupingSeparator: fields[4] as bool,
      defaultCurrency: fields[5] as String,
      favoriteCurrencies: (fields[6] as List?)?.cast<String>(),
      defaultAngleModeIndex: fields[7] as int,
      isDarkMode: fields[8] as bool,
      soundVolume: fields[9] as double,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.soundEnabled)
      ..writeByte(1)
      ..write(obj.hapticEnabled)
      ..writeByte(2)
      ..write(obj.hapticIntensityIndex)
      ..writeByte(3)
      ..write(obj.decimalPlaces)
      ..writeByte(4)
      ..write(obj.useGroupingSeparator)
      ..writeByte(5)
      ..write(obj.defaultCurrency)
      ..writeByte(6)
      ..write(obj.favoriteCurrencies)
      ..writeByte(7)
      ..write(obj.defaultAngleModeIndex)
      ..writeByte(8)
      ..write(obj.isDarkMode)
      ..writeByte(9)
      ..write(obj.soundVolume);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
