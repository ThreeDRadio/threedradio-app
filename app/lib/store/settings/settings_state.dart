import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'settings_state.g.dart';

@JsonSerializable()
class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.system,
  });
  final ThemeMode themeMode;

  Map<String, dynamic> toJson() => _$SettingsStateToJson(this);

  factory SettingsState.fromJson(Map<String, dynamic> json) =>
      _$SettingsStateFromJson(json);
}
