import 'dart:async';

import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoxml/geoxml.dart';
import 'package:time/time.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../gen/assets.gen.dart';
import '../extensions/double_x.dart';
import '../gpx_file.dart';
import '../indexed_point.dart';

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
  /// The loaded gpx data.
  GeoXml get gpx => widget.gpxFile.gpx;

  /// The current location.
  Position? _position;

  /// The timer which updates location.
  late final Timer _timer;

  /// The points, ordered by distance from the current position.
  late List<IndexedPoint> _orderedPoints;

  /// The index of the current point.
  late int _index;

  /// Initialise state.
  @override
  void initState() {
    super.initState();
    _index = -1;
    updatePosition();
    _timer = Timer.periodic(30.seconds, (final t) => updatePosition());
  }

  /// Dispose of the widget.
  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    _position = null;
  }

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
      child = SimpleScaffold(
        title: title,
        body: ListView.builder(
          itemBuilder: (final context, final index) {
            final orderedPoint = _orderedPoints[index];
            final point = orderedPoint.point;
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
              builder: (final context, final controller, final child) {
                final autofocus = index == 0;
                return ListTile(
                  autofocus: autofocus,
                  selected: point.links.isNotEmpty,
                  title: Semantics(
                    liveRegion: autofocus,
                    child: Text('$name: $description'),
                  ),
                  subtitle: Semantics(
                    liveRegion: autofocus,
                    child: Text(
                      // ignore: lines_longer_than_80_chars
                      '${distance.prettyPrintDistance()} at ${degrees.floor()} °',
                    ),
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
                );
              },
              key: ValueKey('Point-${orderedPoint.index}'),
            );
          },
          itemCount: _orderedPoints.length,
          shrinkWrap: true,
        ),
      );
    }
    return Cancel(child: child);
  }

  /// The function to call to update the current position.
  Future<void> updatePosition() async {
    final position = await Geolocator.getCurrentPosition();
    final oldPosition = _position;
    final latitude = position.latitude;
    final longitude = position.longitude;
    if (oldPosition == null ||
        Geolocator.distanceBetween(
              oldPosition.latitude,
              oldPosition.longitude,
              latitude,
              longitude,
            ) >
            position.accuracy) {
      _orderedPoints = [
        for (var i = 0; i < gpx.wpts.length; i++)
          IndexedPoint(index: i, point: gpx.wpts[i]),
      ]..sort(
          (final a, final b) {
            final aPoint = a.point;
            final bPoint = b.point;
            final aDistance = Geolocator.distanceBetween(
              latitude,
              longitude,
              aPoint.lat!,
              aPoint.lon!,
            );
            final bDistance = Geolocator.distanceBetween(
              latitude,
              longitude,
              bPoint.lat!,
              bPoint.lon!,
            );
            return aDistance.compareTo(bDistance);
          },
        );
      if (_orderedPoints.isNotEmpty) {
        final index = _orderedPoints.first.index;
        if (mounted) {
          if (index < _index) {
            await context.playSound(
              Assets.farther.asSound(destroy: true, soundType: SoundType.asset),
            );
          } else if (index > _index) {
            await context.playSound(
              Assets.nearer.asSound(destroy: true, soundType: SoundType.asset),
            );
          }
          _index = index;
        }
      }
      setState(() {
        _position = position;
      });
    }
  }
}
