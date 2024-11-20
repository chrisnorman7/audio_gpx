import 'dart:async';

import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoxml/geoxml.dart';
import 'package:time/time.dart';

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

  /// Initialise state.
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(30.seconds, (final t) async {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _position = position;
      });
    });
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
          text: 'This route is empty.',
          autofocus: true,
        ),
      );
    } else {
      child = SimpleScaffold(
        title: title,
        body: ListView.builder(
          itemBuilder: (final context, final index) {
            final point = points[index];
            return ListTile(
              autofocus: index == 0,
              title: Text(point.name ?? 'Unknown Route'),
              subtitle: Text(point.desc ?? point.cmt ?? point.tag),
              onTap: () {},
            );
          },
          itemCount: points.length,
          shrinkWrap: true,
        ),
      );
    }
    return Cancel(child: child);
  }
}
