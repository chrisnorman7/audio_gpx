import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoxml/geoxml.dart';
import 'package:path/path.dart' as path;

import '../providers.dart';
import 'permissions_screen.dart';

/// A screen which shows all the loaded GPX files.
class GpxFilesScreen extends ConsumerWidget {
  /// Create an instance.
  const GpxFilesScreen({
    super.key,
  });

  /// Build the widget.
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final value = ref.watch(gpxFilesProvider);
    return SimpleScaffold(
      title: 'GPX Files',
      body: value.when(
        data: (final files) {
          if (files.isEmpty) {
            return const CenterText(
              text: 'No files have been loaded.',
              autofocus: true,
            );
          }
          return ListView.builder(
            itemBuilder: (final context, final index) {
              final gpxFile = files[index];
              final gpx = gpxFile.gpx;
              final file = gpxFile.file;
              final metadata = gpx.metadata ??
                  Metadata(
                    desc: file?.path,
                    author: Person(
                      email: Email(
                        domain: 'example.com',
                        id: 'unknown.person',
                      ),
                      link: Link(
                        href: 'www.example.com',
                        text: 'example.com',
                      ),
                      name: 'Unknown Person',
                    ),
                    name: file == null ? 'Unknown' : path.basename(file.path),
                    time: file?.statSync().accessed ?? DateTime.now(),
                  );
              return PerformableActionsListTile(
                actions: [
                  if (file != null)
                    PerformableAction(
                      name: 'Delete',
                      activator: deleteShortcut,
                      invoke: () {
                        context.confirm(
                          message:
                              // ignore: lines_longer_than_80_chars
                              'Really delete the ${metadata.name ?? metadata.desc ?? path.basename(file.path)} route from ${file.path}?',
                          title: 'Delete Route',
                          yesCallback: () {
                            Navigator.pop(context);
                            file.deleteSync(recursive: true);
                            ref.invalidate(gpxFilesProvider);
                          },
                        );
                      },
                    ),
                ],
                autofocus: index == 0,
                title: Text(metadata.name ?? 'Unknown'),
                subtitle: Text(metadata.desc ?? 'Unknown'),
                onTap: () => context.pushWidgetBuilder(
                  (final _) => PermissionsScreen(gpxFile: gpxFile),
                ),
              );
            },
            itemCount: files.length,
            shrinkWrap: true,
          );
        },
        error: ErrorListView.withPositional,
        loading: LoadingWidget.new,
      ),
    );
  }
}
