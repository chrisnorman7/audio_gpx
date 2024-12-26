/// Useful extension methods for doubles.
extension DoubleX on double {
  /// Converts a distance in meters (as a double) to a pretty-printed string.
  ///
  /// If the distance is more than 1000 meters, it is represented in kilometres
  /// with two decimal places (e.g., "1.23 km"). Otherwise, it is represented in
  /// meters (e.g., "750.5 m").
  String prettyPrintDistance() {
    // Check if the distance is greater than or equal to 1000 meters
    if (this >= 1000) {
      // Convert meters to kilometres and format with two decimal places
      final kilometres = this / 1000;
      return '${kilometres.toStringAsFixed(2)} km';
    } else {
      // Format the meters to one decimal place for consistency
      return '${toStringAsFixed(1)} m';
    }
  }
}
