import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:player/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late Future<PackageInfo> pkgInfo;

  @override
  initState() {
    pkgInfo = PackageInfo.fromPlatform();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).about.toUpperCase())),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(24),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: SizedBox(
                height: 250,
                child: Image.asset('assets/images/three_d_logo.png'),
              ),
            ),
            Text(S.of(context).aboutBody),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.house),
                    onPressed: () =>
                        launchUrl(Uri.parse('https://www.threedradio.com')),
                  ),
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.facebookF),
                    onPressed: () => launchUrl(
                      Uri.parse('https://www.facebook.com/threedradio'),
                    ),
                  ),
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.twitter),
                    onPressed: () => launchUrl(
                      Uri.parse('https://www.twitter.com/threedradio'),
                    ),
                  ),
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.instagram),
                    onPressed: () => launchUrl(
                      Uri.parse('https://www.instagram.com/threedradio'),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                S.of(context).credits.toUpperCase(),
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
            Text(S.of(context).creditsBody, textAlign: TextAlign.center),
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: FutureBuilder<PackageInfo>(
                future: pkgInfo,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        Text(
                          S.of(context).version(snapshot.data!.version),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          S
                              .of(context)
                              .versionBuildNumber(snapshot.data!.buildNumber),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    );
                  }
                  return CupertinoActivityIndicator();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
