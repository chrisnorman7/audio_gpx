import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoxml/geoxml.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../gen/assets.gen.dart';
import 'gpx_file.dart';

part 'providers.g.dart';

/// Provide the correct directory for saving files.
@riverpod
Future<Directory> documentsDirectory(final Ref ref) async {
  final appDirectory = await getApplicationDocumentsDirectory();
  final fullPath = path.join(appDirectory.path, 'audio_gpx');
  final directory = Directory(fullPath);
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }
  return directory;
}

/// Provide a list of GPX files.
@riverpod
Future<List<GpxFile>> gpxFiles(final Ref ref) async {
  final gpxFiles = <GpxFile>[];
  if (!kIsWeb) {
    final directory = await ref.watch(documentsDirectoryProvider.future);
    final files = directory.listSync().whereType<File>();
    for (final file in files) {
      final data = file.readAsStringSync();
      final gpx = await GeoXml.fromGpxString(data);
      gpxFiles.add(GpxFile(gpx: gpx, file: file));
    }
  }
  if (gpxFiles.isEmpty) {
    final string = await rootBundle.loadString(Assets.coventryWay);
    final gpx = await GeoXml.fromGpxString(string);
    gpxFiles.add(GpxFile(gpx: gpx));
  }
  return gpxFiles;
}
