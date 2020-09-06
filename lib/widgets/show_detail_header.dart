import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ShowDetailHeader extends StatelessWidget {
  const ShowDetailHeader({
    @required this.title,
    this.subtitle,
    this.imageUrl,
  });
  final String title;
  final String subtitle;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16.0 / 10.0,
      child: Stack(
        children: [
          if (imageUrl != null)
            AspectRatio(
              aspectRatio: 16.0 / 10.0,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                color: Colors.black.withAlpha(140),
                colorBlendMode: BlendMode.multiply,
              ),
            ),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title.toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Divider(
                  color: Theme.of(context).accentColor,
                  thickness: 4,
                ),
              ),
              if (subtitle is String)
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
