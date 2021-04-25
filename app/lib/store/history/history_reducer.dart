import 'package:player/store/history/history_item.dart';
import 'package:redux_entity/redux_entity.dart';

class HistoryReducer
    extends LocalEntityReducer<EntityState<HistoryItem>, HistoryItem> {
  @override
  EntityState<HistoryItem> call(state, action) {
    return super.call(state, action);
  }
}
