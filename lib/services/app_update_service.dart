import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppVersionInfo {
  final String version;
  final int buildNumber;

  const AppVersionInfo({required this.version, required this.buildNumber});

  String get releaseId => buildNumber > 0 ? '$version+$buildNumber' : version;
}

class AppUpdateInfo {
  final AppVersionInfo current;
  final String version;
  final int buildNumber;
  final String downloadUrl;
  final String notes;
  final bool force;

  const AppUpdateInfo({
    required this.current,
    required this.version,
    required this.buildNumber,
    required this.downloadUrl,
    required this.notes,
    required this.force,
  });

  String get releaseId => buildNumber > 0 ? '$version+$buildNumber' : version;
}

class AppUpdateService {
  AppUpdateService._();

  static final AppUpdateService instance = AppUpdateService._();

  static const MethodChannel _channel = MethodChannel('chapterclip/app_update');
  static const String _dismissedReleaseKey = 'dismissed_update_release_id';
  static const String _configuredBaseUrl = String.fromEnvironment(
    'CHAPTERCLIP_UPDATE_BASE_URL',
    defaultValue: '',
  );

  static bool get _hasUpdateSource => _configuredBaseUrl.trim().isNotEmpty;

  static Uri get _baseUri {
    final configured = _configuredBaseUrl.trim();
    return Uri.parse(configured.endsWith('/') ? configured : '$configured/');
  }

  bool get isInAppUpdateSupported => Platform.isAndroid && _hasUpdateSource;

  Future<AppVersionInfo> getCurrentVersionInfo() async {
    final raw = await _channel.invokeMapMethod<String, dynamic>(
      'getAppVersionInfo',
    );
    final version = _normalizeVersion(raw?['version']?.toString() ?? '');
    final buildNumber = _toInt(raw?['buildNumber']) ?? 0;
    if (version.isEmpty) {
      throw Exception('Current app version is missing');
    }
    return AppVersionInfo(version: version, buildNumber: buildNumber);
  }

  Future<AppUpdateInfo?> checkForUpdate() async {
    if (!isInAppUpdateSupported) return null;

    final current = await getCurrentVersionInfo();
    final manifest = await _loadManifest();
    final latest = _parseVersionInfo(manifest);
    final downloadUrl = _resolveDownloadUrl(manifest);
    if (downloadUrl.isEmpty) {
      throw Exception('Update manifest is missing a download URL');
    }

    final comparison = _compareRelease(
      latest.version,
      latest.buildNumber,
      current.version,
      current.buildNumber,
    );
    if (comparison <= 0) return null;

    return AppUpdateInfo(
      current: current,
      version: latest.version,
      buildNumber: latest.buildNumber,
      downloadUrl: downloadUrl,
      notes: _normalizeNotes(manifest['notes']),
      force: _toBool(manifest['force']),
    );
  }

  Future<File> downloadUpdate(
    AppUpdateInfo info, {
    void Function(int received, int total)? onProgress,
  }) async {
    final baseDir = await getApplicationSupportDirectory();
    final updateDir =
        Directory('${baseDir.path}${Platform.pathSeparator}updates');
    await updateDir.create(recursive: true);

    final suffix = info.buildNumber > 0 ? '-${info.buildNumber}' : '';
    final file = File(
      '${updateDir.path}${Platform.pathSeparator}'
      'chapterclip-${info.version}$suffix.apk',
    );
    if (await file.exists()) {
      await file.delete();
    }

    final uri =
        _withCacheBuster(Uri.parse(info.downloadUrl), token: info.releaseId);
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to download update (${response.statusCode})');
      }

      final sink = file.openWrite();
      var received = 0;
      final total = response.contentLength;
      await for (final chunk in response) {
        received += chunk.length;
        sink.add(chunk);
        onProgress?.call(received, total);
      }
      await sink.close();
      return file;
    } catch (_) {
      if (await file.exists()) {
        await file.delete();
      }
      rethrow;
    } finally {
      client.close(force: true);
    }
  }

  Future<void> installDownloaded(String path) {
    return _channel.invokeMethod<void>('installApk', {'path': path});
  }

  Future<bool> isReleaseDismissed(String releaseId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_dismissedReleaseKey) == releaseId;
  }

  Future<void> rememberDismissedRelease(String releaseId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dismissedReleaseKey, releaseId);
  }

  Future<void> clearDismissedRelease() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dismissedReleaseKey);
  }

  Future<Map<String, dynamic>> _loadManifest() async {
    final manifestUri = _withCacheBuster(_baseUri.resolve('update.json'));
    try {
      final response = await _getText(manifestUri);
      final data = jsonDecode(response);
      if (data is Map<String, dynamic>) return data;
      if (data is Map) {
        return data.map((key, value) => MapEntry(key.toString(), value));
      }
      throw Exception('Update manifest format is invalid');
    } on HttpException catch (error) {
      if (error.message.contains('404')) {
        return _loadVersionFallback();
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _loadVersionFallback() async {
    final version = _normalizeVersion(
      await _getText(_withCacheBuster(_baseUri.resolve('version.txt'))),
    );
    if (version.isEmpty) {
      throw Exception('version.txt is empty');
    }
    return {
      'version': version,
      'apkUrl': _baseUri.resolve('chapterclip-android.apk').toString(),
    };
  }

  Future<String> _getText(Uri uri) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Failed to load $uri (${response.statusCode})',
          uri: uri,
        );
      }
      return utf8.decode(await response.fold<List<int>>([], (bytes, chunk) {
        bytes.addAll(chunk);
        return bytes;
      }));
    } finally {
      client.close(force: true);
    }
  }

  String _resolveDownloadUrl(Map<String, dynamic> manifest) {
    for (final key in const ['apkUrl', 'url', 'apk', 'fileName']) {
      final value = manifest[key]?.toString().trim() ?? '';
      if (value.isEmpty) continue;
      if (value.startsWith('http://') || value.startsWith('https://')) {
        return value;
      }
      return _baseUri.resolve(value).toString();
    }
    return _baseUri.resolve('chapterclip-android.apk').toString();
  }

  Uri _withCacheBuster(Uri uri, {String? token}) {
    final query = <String, String>{...uri.queryParameters};
    query['t'] = token ?? DateTime.now().millisecondsSinceEpoch.toString();
    return uri.replace(queryParameters: query);
  }

  AppVersionInfo _parseVersionInfo(Map<String, dynamic> manifest) {
    final version = _normalizeVersion(manifest['version']?.toString() ?? '');
    if (version.isEmpty) {
      throw Exception('Update manifest is missing a valid version');
    }
    return AppVersionInfo(
      version: version,
      buildNumber: _toInt(manifest['buildNumber']) ?? 0,
    );
  }

  String _normalizeVersion(String value) {
    return value.trim().replaceFirst(RegExp(r'^[vV]'), '');
  }

  String _normalizeNotes(dynamic value) {
    if (value == null) return '';
    if (value is Iterable) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .join('\n');
    }
    return value.toString().trim();
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  bool _toBool(dynamic value) {
    if (value is bool) return value;
    final text = value?.toString().trim().toLowerCase() ?? '';
    return text == '1' || text == 'true' || text == 'yes';
  }

  int _compareRelease(
    String leftVersion,
    int leftBuild,
    String rightVersion,
    int rightBuild,
  ) {
    final versionCompare = _compareVersionStrings(leftVersion, rightVersion);
    if (versionCompare != 0) return versionCompare;
    return leftBuild.compareTo(rightBuild);
  }

  int _compareVersionStrings(String left, String right) {
    final leftParts = left.split('.');
    final rightParts = right.split('.');
    final maxLength = leftParts.length > rightParts.length
        ? leftParts.length
        : rightParts.length;
    for (var index = 0; index < maxLength; index++) {
      final leftValue =
          index < leftParts.length ? _numericPrefix(leftParts[index]) : 0;
      final rightValue =
          index < rightParts.length ? _numericPrefix(rightParts[index]) : 0;
      if (leftValue != rightValue) return leftValue.compareTo(rightValue);
    }
    return 0;
  }

  int _numericPrefix(String value) {
    final match = RegExp(r'\d+').firstMatch(value);
    return int.tryParse(match?.group(0) ?? '') ?? 0;
  }
}
