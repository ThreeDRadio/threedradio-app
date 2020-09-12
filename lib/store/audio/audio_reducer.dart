import 'package:player/store/audio/audio_actions.dart';
import 'package:player/store/audio/audio_state.dart';

AudioState audioReducer(AudioState state, dynamic action) {
  if (action is AudioStateChange) {
    return state.copyWith(state: action.state);
  }
  if (action is MediaItemChange) {
    return state.copyWith(currentItem: action.item);
  }
  return state;
}
