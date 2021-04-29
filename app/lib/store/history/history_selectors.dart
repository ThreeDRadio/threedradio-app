import 'package:player/store/app_state.dart';
import 'package:player/store/history/history_item.dart';
import 'package:redux_entity/redux_entity.dart';

EntityState<HistoryItem> getState(AppState s) => s.history;

List<HistoryItem> getHistoryItems(AppState s) {
  return getState(s).entities.values.toList();
}

HistoryItem? getLastPlayed(AppState s) {
  final items = getHistoryItems(s);

  if (items.isEmpty) {
    return null;
  }

  items.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  return items.last;
}

List<HistoryItem> getPlayableItems(AppState s) {
  final oldest = DateTime.now().subtract(const Duration(days: 28));
  return getHistoryItems(s).where((element) {
    try {
      return DateTime.parse(element.episodeDate).isAfter(oldest);
    } catch (exception) {
      return false;
    }
  }).toList();
}

List<HistoryItem> getUnfinishedPlayableItems(AppState s) {
  return getPlayableItems(s)
      .where((element) => (element.showLength - element.position).inMinutes > 5)
      .toList();
}

HistoryItem? getLatestPlayable(AppState s) {
  final items = getUnfinishedPlayableItems(s);

  if (items.isEmpty) {
    return null;
  }

  items.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  return items.last;
}
