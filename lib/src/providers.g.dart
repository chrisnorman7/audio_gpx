// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$documentsDirectoryHash() =>
    r'05f06a99cb363dd90aca0088dbe5d4d09803ece6';

/// Provide the correct directory for saving files.
///
/// Copied from [documentsDirectory].
@ProviderFor(documentsDirectory)
final documentsDirectoryProvider =
    AutoDisposeFutureProvider<Directory>.internal(
  documentsDirectory,
  name: r'documentsDirectoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$documentsDirectoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DocumentsDirectoryRef = AutoDisposeFutureProviderRef<Directory>;
String _$gpxFilesHash() => r'543d298ccf1156964421d9b214e6f216ba5a96ed';

/// Provide a list of GPX files.
///
/// Copied from [gpxFiles].
@ProviderFor(gpxFiles)
final gpxFilesProvider = AutoDisposeFutureProvider<List<GpxFile>>.internal(
  gpxFiles,
  name: r'gpxFilesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$gpxFilesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GpxFilesRef = AutoDisposeFutureProviderRef<List<GpxFile>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
