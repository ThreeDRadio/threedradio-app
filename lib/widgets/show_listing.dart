import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:player/generated/l10n.dart';
import 'package:player/services/wp_schedule_api.dart';

class ShowListing extends StatelessWidget {
  const ShowListing({
    required this.title,
    this.subtitle,
    required this.heroTag,
    this.thumbnail,
    this.onTap,
    this.action,
    Key? key,
  }) : super(key: key);

  factory ShowListing.fromShow(
    Show show, {
    required String heroTag,
    VoidCallback? onTap,
    Widget? action,
  }) {
    return ShowListing(
      heroTag: heroTag,
      onTap: onTap,
      title: show.title.text,
      thumbnail: show.thumbnail is String ? show.thumbnail : null,
      subtitle: show.meta.subtitle2?[0],
      action: action,
    );
  }
  final VoidCallback? onTap;
  final String heroTag;
  final String? thumbnail;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 3,
          child: Hero(
            tag: heroTag,
            child: Stack(
              children: [
                if (thumbnail is String)
                  AspectRatio(
                    aspectRatio: 3,
                    child: CachedNetworkImage(
                      imageUrl: thumbnail!,
                      fit: BoxFit.cover,
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.black.withAlpha(140),
                      Colors.black.withAlpha(0)
                    ], stops: [
                      0,
                      0.8
                    ]),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .copyWith(
                                shadows: [
                                  Shadow(offset: Offset(0, 2)),
                                ],
                              ),
                            ),
                            if (subtitle != null)
                              Text(
                                subtitle!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(
                                  shadows: [
                                    Shadow(offset: Offset(0, 2)),
                                  ],
                                ),
                              )
                            else
                              Text(
                                S.of(context).defaultShortDescription,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(
                                  shadows: [
                                    Shadow(offset: Offset(0, 2)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (action != null) action!
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
