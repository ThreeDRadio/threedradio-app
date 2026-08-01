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
    super.key,
  });

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
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
        side: BorderSide(color: Theme.of(context).colorScheme.onSurface),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: AlignmentGeometry.topRight,
              children: [
                Hero(
                  tag: heroTag,
                  child: AspectRatio(
                    aspectRatio: 3,
                    child: (thumbnail is String)
                        ? CachedNetworkImage(
                            imageUrl: thumbnail!,
                            fit: BoxFit.cover,
                          )
                        : Placeholder(),
                  ),
                ),
                if (action != null)
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: action!,
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    HtmlUnescape().convert(title).toUpperCase(),
                    style: Theme.of(context).textTheme.headlineSmall!,
                  ),
                  if (subtitle != null)
                    Text(
                      '$subtitle',
                      style: Theme.of(context).textTheme.bodyMedium!,
                    )
                  else
                    Text(S.of(context).defaultShortDescription),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
