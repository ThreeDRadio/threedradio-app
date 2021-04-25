import 'package:json_annotation/json_annotation.dart';

part 'favourites_actions.g.dart';

@JsonSerializable()
class Favourite {
  const Favourite({required this.showId});
  factory Favourite.fromJson(Map<String, dynamic> json) =>
      _$FavouriteFromJson(json);
  Map<String, dynamic> toJson() => _$FavouriteToJson(this);
  final String showId;

  String get id => showId;
}
