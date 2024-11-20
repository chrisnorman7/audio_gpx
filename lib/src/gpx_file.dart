import 'dart:io';

import 'package:geoxml/geoxml.dart';

/// A loaded [gpx] [file].
class GpxFile {
  /// Create an instance.
  const GpxFile({
    required this.gpx,
    this.file,
  });

  /// The file that [gpx] was loaded from.
  ///
  /// If [file] is `null`, then [gpx] was loaded from an asset.
  final File? file;

  /// The GPX data that was loaded from [file].
  final GeoXml gpx;
}
