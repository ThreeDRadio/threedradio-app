import 'package:player/store/settings/settings_actions.dart';
import 'package:player/store/settings/settings_state.dart';

SettingsState settingsReducer(SettingsState state, dynamic action) {
  if (action is SetThemeMode) {
    return SettingsState(themeMode: action.mode);
  }
  return state;
}
