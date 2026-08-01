import 'package:player/store/history/history_item.dart';
import 'package:redux_entity/redux_entity.dart';

class HistoryReducer
    extends LocalEntityReducer<EntityState<HistoryItem>, HistoryItem> {
  @override
  // ignore: unnecessary_overrides
  EntityState<HistoryItem> call(state, action) {
    return super.call(state, action);
  }
}
