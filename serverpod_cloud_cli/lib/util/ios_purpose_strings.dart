import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';
import 'package:serverpod_cloud_cli/util/flutter_plugin_sources.dart';
import 'package:xml/xml.dart';
import 'package:yaml/yaml.dart';

/// The path of the Info.plist of the iOS Runner app, relative to the app.
const iosInfoPlistPath = 'ios/Runner/Info.plist';

/// The path of the CocoaPods Podfile of the iOS app, relative to the app.
const _iosPodfilePath = 'ios/Podfile';

/// The path of the native code of the iOS Runner app, relative to the app.
const _iosRunnerPath = 'ios/Runner';

/// A purpose string that the code of an iOS app needs and that the
/// Info.plist lacks or leaves empty, which App Store Connect rejects the
/// build for.
class IosPurposeStringIssue {
  /// The Info.plist key of the purpose string, such as
  /// `NSCameraUsageDescription`.
  final String key;

  /// What the purpose string explains the use of, such as `the camera`.
  final String feature;

  /// The code of the app that uses the [feature]: package names, each with
  /// the Podfile setting that turns the use on or the privacy sensitive APIs
  /// its code references where known, and `ios/Runner` for the app's own
  /// native code.
  final List<String> usedBy;

  /// Whether the key is set to an empty value, rather than missing.
  final bool isEmpty;

  const IosPurposeStringIssue({
    required this.key,
    required this.feature,
    required this.usedBy,
    required this.isEmpty,
  });
}

/// Reads the names of all packages in [lockfile], the direct and the
/// transitive dependencies.
///
/// Throws [FailureException] if [lockfile] is missing or cannot be read or
/// parsed.
Set<String> readLockfilePackageNames(File lockfile) {
  if (!lockfile.existsSync()) {
    throw FailureException(
      error: 'pubspec.lock is missing.',
      hint: 'Run "flutter pub get" in the app directory.',
    );
  }
  final Object? document;
  try {
    document = loadYaml(lockfile.readAsStringSync());
  } on FileSystemException catch (e) {
    throw FailureException(error: 'Failed to read pubspec.lock: ${e.message}');
  } on YamlException catch (e) {
    throw FailureException(error: 'Failed to parse pubspec.lock: ${e.message}');
  }
  final packages = document is YamlMap ? document['packages'] : null;
  if (packages is! YamlMap) return const {};
  return {for (final name in packages.keys) name.toString()};
}

/// Finds the purpose strings that the iOS app in [appDirectory] lacks or
/// leaves empty in its Info.plist. A purpose string is needed when the
/// app's code uses the feature it explains:
///
/// - one of [packages] is a plugin known to use the feature, or, for
///   `permission_handler`, the Podfile turns on the permission of the
///   feature;
/// - the iOS code of another plugin of the app references a privacy
///   sensitive API of the feature, such as `AVCaptureDevice` for the
///   camera. The plugins and their paths come from the
///   `.flutter-plugins-dependencies` file that `flutter pub get` writes, so
///   plugins in the pub cache, path and git dependencies, and plugins in
///   the app's own repository are all checked. Without that file, only the
///   known plugins are;
/// - the app's own native code in `ios/Runner` references such an API.
///
/// Returns the issues in a fixed order of the keys, or an empty list when
/// there are none.
///
/// Throws [FailureException] if a purpose string is needed and the
/// Info.plist is missing or cannot be parsed.
List<IosPurposeStringIssue> findIosPurposeStringIssues(
  Directory appDirectory, {
  required Set<String> packages,
}) {
  final required = _requiredPurposeStrings(appDirectory, packages);
  final Map<String, XmlElement> values;
  try {
    values = _readInfoPlistValues(appDirectory);
  } on FailureException {
    if (required.isEmpty) return const [];
    rethrow;
  }
  final issues = <IosPurposeStringIssue>[];
  for (final MapEntry(key: key, value: feature)
      in _purposeStringFeatures.entries) {
    final usedBy = required[key];
    if (usedBy == null) continue;
    final value = values[key];
    final isEmpty = value != null && _isEmptyString(value);
    if (value == null || isEmpty) {
      issues.add(
        IosPurposeStringIssue(
          key: key,
          feature: feature,
          usedBy: usedBy,
          isEmpty: isEmpty,
        ),
      );
    }
  }
  return issues;
}

/// The purpose strings that [packages] need, each with the packages that
/// need it.
Map<String, List<String>> _requiredPurposeStrings(
  Directory appDirectory,
  Set<String> packages,
) {
  final required = <String, List<String>>{};
  void add(String key, String source) => (required[key] ??= []).add(source);

  for (final MapEntry(key: package, value: keys)
      in _purposeStringsOfPackages.entries) {
    if (!packages.contains(package)) continue;
    for (final key in keys) {
      add(key, package);
    }
  }
  final plugins = readFlutterPlugins(appDirectory, 'ios') ?? const [];
  for (final plugin in plugins) {
    if (_isKnownPlugin(plugin.name)) continue;
    _addApiUses(plugin.name, [
      Directory(p.join(plugin.path, 'ios')),
      Directory(p.join(plugin.path, 'darwin')),
    ], add);
  }
  _addApiUses(_iosRunnerPath, [
    Directory(p.join(appDirectory.path, _iosRunnerPath)),
  ], add);
  if (packages.any(_permissionHandlerPackages.contains)) {
    for (final setting in _enabledPermissionHandlerSettings(appDirectory)) {
      for (final key in _purposeStringsOfPermissionHandler[setting] ?? []) {
        add(key, 'permission_handler ($setting in $_iosPodfilePath)');
      }
    }
  }
  return required;
}

/// Adds, with [add], each purpose string whose privacy sensitive APIs the
/// native source files in [directories] reference outside comments, for
/// [source], followed by the APIs it references.
void _addApiUses(
  String source,
  List<Directory> directories,
  void Function(String key, String source) add,
) {
  final apisByKey = <String, Set<String>>{};
  for (final code in readSourceCode(
    directories,
    extensions: _nativeSourceExtensions,
  )) {
    for (final (:api, :keys, :reference) in _apiReferences) {
      if (!reference.hasMatch(code)) continue;
      for (final key in keys) {
        (apisByKey[key] ??= {}).add(api);
      }
    }
  }
  for (final MapEntry(key: key, value: apis) in apisByKey.entries) {
    add(key, '$source (${apis.join(', ')})');
  }
}

/// Whether the purpose strings of the plugin [name] come from the list of
/// known plugins, either as the package itself or as its iOS implementation
/// package, such as `camera_avfoundation` for `camera`.
bool _isKnownPlugin(String name) {
  if (_permissionHandlerPackages.contains(name)) return true;
  if (_purposeStringsOfPackages.containsKey(name)) return true;
  return _federatedImplementationSuffixes.any(
    (suffix) =>
        name.endsWith(suffix) &&
        _purposeStringsOfPackages.containsKey(
          name.substring(0, name.length - suffix.length),
        ),
  );
}

/// The `PERMISSION_*` preprocessor settings that the Podfile of the iOS app
/// in [appDirectory] turns on for `permission_handler`, outside comments.
Set<String> _enabledPermissionHandlerSettings(Directory appDirectory) {
  final file = File(p.join(appDirectory.path, _iosPodfilePath));
  if (!file.existsSync()) return const {};
  final String content;
  try {
    content = file.readAsStringSync();
  } on FileSystemException {
    return const {};
  }
  return {
    for (final line in content.split('\n'))
      for (final match in _permissionHandlerSetting.allMatches(
        line.split('#').first,
      ))
        ?match.group(1),
  };
}

/// The values of the top-level dictionary of the Info.plist of the iOS app
/// in [appDirectory], by key.
///
/// Throws [FailureException] if the Info.plist is missing or cannot be
/// parsed.
Map<String, XmlElement> _readInfoPlistValues(Directory appDirectory) {
  final file = File(p.join(appDirectory.path, iosInfoPlistPath));
  if (!file.existsSync()) {
    throw FailureException(
      error: '$iosInfoPlistPath is missing.',
      hint:
          'Recreate the ios project with '
          '"flutter create --platforms=ios ." in the app directory.',
    );
  }
  final XmlDocument document;
  try {
    document = XmlDocument.parse(file.readAsStringSync());
  } on FileSystemException catch (e) {
    throw FailureException(
      error: 'Failed to read $iosInfoPlistPath: ${e.message}',
    );
  } on XmlException catch (e) {
    throw FailureException(
      error: 'Failed to parse $iosInfoPlistPath: ${e.message}',
    );
  }
  final elements =
      document.rootElement.childElements
          .where((element) => element.name.local == 'dict')
          .firstOrNull
          ?.childElements
          .toList() ??
      const <XmlElement>[];
  return {
    for (var index = 0; index + 1 < elements.length; index += 2)
      if (elements[index].name.local == 'key')
        elements[index].innerText.trim(): elements[index + 1],
  };
}

bool _isEmptyString(XmlElement value) =>
    value.name.local == 'string' && value.innerText.trim().isEmpty;

const _permissionHandlerPackages = {
  'permission_handler',
  'permission_handler_apple',
};

/// The name endings of the iOS implementation packages of federated
/// plugins.
const _federatedImplementationSuffixes = [
  '_ios',
  '_darwin',
  '_apple',
  '_avfoundation',
  '_foundation',
];

const _nativeSourceExtensions = {'.swift', '.m', '.mm'};

/// Each API of [_purposeStringsOfApis] with the purpose strings it needs
/// and a pattern of a reference to it as a whole word.
final _apiReferences = [
  for (final MapEntry(key: api, value: keys) in _purposeStringsOfApis.entries)
    (api: api, keys: keys, reference: RegExp('\\b$api\\b')),
];

/// A `PERMISSION_*=1` preprocessor setting, with the name in group 1.
final _permissionHandlerSetting = RegExp(r'\b(PERMISSION_[A-Z_]+)\s*=\s*1\b');

const _camera = 'NSCameraUsageDescription';
const _microphone = 'NSMicrophoneUsageDescription';
const _photoLibrary = 'NSPhotoLibraryUsageDescription';
const _photoLibraryAdd = 'NSPhotoLibraryAddUsageDescription';
const _locationWhenInUse = 'NSLocationWhenInUseUsageDescription';
const _locationAlways = 'NSLocationAlwaysAndWhenInUseUsageDescription';
const _contacts = 'NSContactsUsageDescription';
const _calendars = 'NSCalendarsUsageDescription';
const _calendarsFullAccess = 'NSCalendarsFullAccessUsageDescription';
const _reminders = 'NSRemindersUsageDescription';
const _bluetooth = 'NSBluetoothAlwaysUsageDescription';
const _speechRecognition = 'NSSpeechRecognitionUsageDescription';
const _tracking = 'NSUserTrackingUsageDescription';
const _healthShare = 'NSHealthShareUsageDescription';
const _healthUpdate = 'NSHealthUpdateUsageDescription';
const _motion = 'NSMotionUsageDescription';
const _mediaLibrary = 'NSAppleMusicUsageDescription';

/// The purpose strings that App Store Connect rejects a build without when
/// its code uses the feature they explain, with what each explains the use
/// of, in the order issues are reported. Purpose strings that only make a
/// feature fail at run time, such as `NSFaceIDUsageDescription`, are not
/// listed.
const _purposeStringFeatures = {
  _camera: 'the camera',
  _microphone: 'the microphone',
  _photoLibrary: 'the photo library',
  _photoLibraryAdd: 'saving to the photo library',
  _locationWhenInUse: 'the location while the app is in use',
  _locationAlways: 'the location in the background',
  _contacts: 'the contacts',
  _calendars: 'the calendars',
  _calendarsFullAccess: 'full access to the calendars',
  _reminders: 'the reminders',
  _bluetooth: 'Bluetooth',
  _speechRecognition: 'speech recognition',
  _tracking: 'tracking across apps',
  _healthShare: 'reading health data',
  _healthUpdate: 'writing health data',
  _motion: 'motion and fitness data',
  _mediaLibrary: 'the media library',
};

/// The purpose strings that a package needs, because its iOS code uses
/// the feature they explain, by package name.
const _purposeStringsOfPackages = {
  'app_tracking_transparency': [_tracking],
  'camera': [_camera, _microphone],
  'contacts_service': [_contacts],
  'device_calendar': [_calendars],
  'flutter_blue_plus': [_bluetooth],
  'flutter_contacts': [_contacts],
  'flutter_reactive_ble': [_bluetooth],
  'flutter_sound': [_microphone],
  'gal': [_photoLibraryAdd],
  'geolocator': [_locationWhenInUse],
  'health': [_healthShare, _healthUpdate],
  'image_picker': [_camera, _photoLibrary],
  'location': [_locationWhenInUse],
  'mobile_scanner': [_camera],
  'pedometer': [_motion],
  'photo_manager': [_photoLibrary],
  'record': [_microphone],
  'speech_to_text': [_microphone, _speechRecognition],
};

/// The purpose strings that code needs when it references a privacy
/// sensitive API, by API.
const _purposeStringsOfApis = {
  'AVCaptureDevice': [_camera],
  'AVAudioRecorder': [_microphone],
  'requestRecordPermission': [_microphone],
  'PHPhotoLibrary': [_photoLibrary],
  'UIImageWriteToSavedPhotosAlbum': [_photoLibraryAdd],
  'CLLocationManager': [_locationWhenInUse],
  'requestAlwaysAuthorization': [_locationAlways],
  'CNContactStore': [_contacts],
  'EKEventStore': [_calendars],
  'CBCentralManager': [_bluetooth],
  'CBPeripheralManager': [_bluetooth],
  'SFSpeechRecognizer': [_speechRecognition],
  'ATTrackingManager': [_tracking],
  'HKHealthStore': [_healthShare, _healthUpdate],
  'CMMotionActivityManager': [_motion],
  'CMPedometer': [_motion],
  'MPMediaLibrary': [_mediaLibrary],
};

/// The purpose strings that `permission_handler` needs, by the Podfile
/// setting that turns on the permission.
const _purposeStringsOfPermissionHandler = {
  'PERMISSION_APP_TRACKING_TRANSPARENCY': [_tracking],
  'PERMISSION_BLUETOOTH': [_bluetooth],
  'PERMISSION_CAMERA': [_camera],
  'PERMISSION_CONTACTS': [_contacts],
  'PERMISSION_EVENTS': [_calendars],
  'PERMISSION_EVENTS_FULL_ACCESS': [_calendarsFullAccess],
  'PERMISSION_LOCATION': [_locationWhenInUse, _locationAlways],
  'PERMISSION_LOCATION_WHENINUSE': [_locationWhenInUse],
  'PERMISSION_MEDIA_LIBRARY': [_mediaLibrary],
  'PERMISSION_MICROPHONE': [_microphone],
  'PERMISSION_PHOTOS': [_photoLibrary],
  'PERMISSION_PHOTOS_ADD_ONLY': [_photoLibraryAdd],
  'PERMISSION_REMINDERS': [_reminders],
  'PERMISSION_SENSORS': [_motion],
  'PERMISSION_SPEECH_RECOGNIZER': [_speechRecognition],
};
