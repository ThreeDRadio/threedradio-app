import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:player/services/wp_schedule_api.dart';

class ShowListing extends StatelessWidget {
  const ShowListing({
    @required this.data,
    this.onTap,
    Key key,
  }) : super(key: key);

  final Show data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 3,
          child: Stack(
            children: [
              if (data?.thumbnail is String)
                AspectRatio(
                  aspectRatio: 3,
                  child: CachedNetworkImage(
                    imageUrl: data?.thumbnail,
                    fit: BoxFit.cover,
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.black.withAlpha(160),
                    Colors.black.withAlpha(0)
                  ], stops: [
                    0,
                    0.8
                  ]),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title.text ?? '',
                      style: Theme.of(context).textTheme.headline5.copyWith(
                        shadows: [
                          Shadow(offset: Offset(0, 2)),
                        ],
                      ),
                    ),
                    if (data.meta.subtitle2 != null)
                      Text(
                        data.meta.subtitle2[0],
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                          shadows: [
                            Shadow(offset: Offset(0, 2)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
