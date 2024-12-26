import 'package:geoxml/geoxml.dart';

/// A class which holds an [index] and a [point].
class IndexedPoint {
  /// Create an instance.
  const IndexedPoint({required this.index, required this.point});

  /// The index of [point].
  final int index;

  /// The point which resides at [index].
  final Wpt point;
}
