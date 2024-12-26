import 'dart:async';

import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoxml/geoxml.dart';
import 'package:time/time.dart';
import 'package:url_launcher/url_launcher.dart';

import '../extensions/double_x.dart';
import '../gpx_file.dart';

/// A screen to help navigate a single [gpxFile].
class GpxFileScreen extends StatefulWidget {
  /// Create an instance.
  const GpxFileScreen({
    required this.gpxFile,
    super.key,
  });

  /// The gpx file to use.
  final GpxFile gpxFile;

  /// Create state for this widget.
  @override
  GpxFileScreenState createState() => GpxFileScreenState();
}

/// State for [GpxFileScreen].
class GpxFileScreenState extends State<GpxFileScreen> {
  /// The current location.
  Position? _position;

  /// The timer which updates location.
  late final Timer _timer;

  /// The index of the target point.
  late int _index;

  /// Initialise state.
  @override
  void initState() {
    super.initState();
    Geolocator.getCurrentPosition()
        .then((final position) => setState(() => _position = position));
    _timer = Timer.periodic(30.seconds, (final t) async {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _position = position;
      });
    });
    _index = 0;
  }

  /// Dispose of the widget.
  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    _position = null;
  }

  /// The loaded gpx data.
  GeoXml get gpx => widget.gpxFile.gpx;

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final Widget child;
    final position = _position;
    final title = gpx.metadata?.name ?? 'Untitled Route';
    final points = gpx.wpts;
    if (position == null) {
      child = const SimpleScaffold(
        title: 'Getting Location',
        body: CenterText(
          text: 'Getting current location...',
          autofocus: true,
        ),
      );
    } else if (points.isEmpty) {
      child = SimpleScaffold(
        title: title,
        body: const CenterText(
          text: 'This route has no waypoints.',
          autofocus: true,
        ),
      );
    } else {
      final sortedPoints = List<Wpt>.from(points)
        ..sort(
          (final a, final b) {
            final aDistance = Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              a.lat!,
              a.lon!,
            );
            final bDistance = Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              b.lat!,
              b.lon!,
            );
            return aDistance.compareTo(bDistance);
          },
        );
      child = SimpleScaffold(
        title: title,
        body: ListView.builder(
          itemBuilder: (final context, final index) {
            final point = sortedPoints[index];
            final name = point.name ?? 'Unknown Route';
            final description = point.desc ?? point.cmt ?? point.tag;
            final distance = Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              point.lat!,
              point.lon!,
            );
            final degrees = Geolocator.bearingBetween(
              point.lat!,
              point.lon!,
              position.latitude,
              position.longitude,
            );
            final menuButtons = <MenuItemButton>[];
            for (var i = 0; i < point.links.length; i++) {
              final link = point.links[i];
              menuButtons.add(
                MenuItemButton(
                  autofocus: i == 0,
                  child: Text(link.text ?? link.href),
                  onPressed: () => launchUrl(Uri.parse(link.href)),
                ),
              );
            }
            return MenuAnchor(
              menuChildren: menuButtons,
              builder: (final context, final controller, final child) =>
                  ListTile(
                autofocus: index == 0,
                title: Text('$name: $description'),
                subtitle: Text(
                  '${distance.prettyPrintDistance()} at ${degrees.floor()} °',
                ),
                onTap: () {
                  if (menuButtons.isEmpty) {
                    context.showMessage(message: 'This point has no links.');
                  } else if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
              ),
            );
          },
          itemCount: sortedPoints.length,
          shrinkWrap: true,
        ),
      );
    }
    return Cancel(child: child);
  }
}
