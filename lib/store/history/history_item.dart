import 'package:json_annotation/json_annotation.dart';

part 'history_item.g.dart';

@JsonSerializable()
class HistoryItem {
  HistoryItem({
    required this.id,
    required this.showId,
    required this.episodeDate,
    required this.position,
    required this.showLength,
  }) {
    timestamp = DateTime.now();
  }
  factory HistoryItem.fromJson(Map<String, dynamic> json) =>
      _$HistoryItemFromJson(json);
  Map<String, dynamic> toJson() => _$HistoryItemToJson(this);

  final String id;
  final String showId;
  final String episodeDate;
  final Duration position;
  final Duration showLength;
  late DateTime timestamp;
}
