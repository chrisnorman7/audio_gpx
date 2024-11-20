import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../gpx_file.dart';
import 'gpx_file_screen.dart';

/// A screen which shows permissions.
class PermissionsScreen extends StatefulWidget {
  /// Create an instance.
  const PermissionsScreen({
    required this.gpxFile,
    super.key,
  });

  /// The GPX file to send to the eventual [GpxFileScreen].
  final GpxFile gpxFile;

  /// Create state for this widget.
  @override
  PermissionsScreenState createState() => PermissionsScreenState();
}

/// State for [PermissionsScreen].
class PermissionsScreenState extends State<PermissionsScreen> {
  /// Whether or not the service is enabled.
  bool? _serviceEnabled;

  /// The location permissions.
  LocationPermission? _permission;

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    switch (_serviceEnabled) {
      case null:
        Geolocator.isLocationServiceEnabled().then(
          (final value) => setState(() {
            _serviceEnabled = value;
          }),
        );
        return const SimpleScaffold(
          title: 'Location Service',
          body: CenterText(
            text: 'Checking whether the location service is enabled.',
            autofocus: true,
          ),
        );
      case false:
        return SimpleScaffold(
          actions: [
            IconButton(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
          ],
          title: 'Location Service',
          body: const CenterText(
            text:
                // ignore: lines_longer_than_80_chars
                'The location service is disabled. You must enable it for this app to work.',
            autofocus: true,
          ),
        );
      case true:
        final permission = _permission;
        if (permission == null) {
          Geolocator.checkPermission()
              .then((final value) => setState(() => _permission = value));
          return const SimpleScaffold(
            title: 'Location Permissions',
            body: CenterText(
              text: 'Loading the location permissions.',
              autofocus: true,
            ),
          );
        }
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          return GpxFileScreen(gpxFile: widget.gpxFile);
        } else {
          return SimpleScaffold(
            actions: [
              IconButton(
                onPressed: () => setState(() {}),
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
            title: 'Error',
            body: CenterText(
              text:
                  // ignore: lines_longer_than_80_chars
                  'This app needs location permissions in order to work (${permission.name}).',
              autofocus: true,
            ),
          );
        }
    }
  }
}
