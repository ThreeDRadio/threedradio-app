import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:player/generated/l10n.dart';
import 'package:player/services/new_api/dto/show_dto.dart';

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
    ShowDto show, {
    required String heroTag,
    VoidCallback? onTap,
    Widget? action,
  }) {
    return ShowListing(
      heroTag: heroTag,
      onTap: onTap,
      title: show.name,
      thumbnail: show.acf?.program_featured_image?.medium is String
          ? show.acf!.program_featured_image!.medium!
          : null,
      subtitle: show.acf?.hosted_by?.firstOrNull?.post_title,
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
    return Material(
      child: Card(
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
                    Positioned(
                      top: 0,
                      left: 0,
                      bottom: 0,
                      right: 0,
                      child: CachedNetworkImage(
                        imageUrl: thumbnail!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withAlpha(140),
                          Colors.black.withAlpha(0),
                        ],
                        stops: [0, 0.8],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                HtmlUnescape().convert(title),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                      shadows: [Shadow(offset: Offset(0, 2))],
                                    ),
                              ),
                              if (subtitle != null)
                                Text(
                                  subtitle!,
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(
                                        shadows: [Shadow(offset: Offset(0, 2))],
                                      ),
                                )
                              else
                                Text(
                                  S.of(context).defaultShortDescription,
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(
                                        shadows: [Shadow(offset: Offset(0, 2))],
                                      ),
                                ),
                            ],
                          ),
                        ),
                        if (action != null) action!,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
