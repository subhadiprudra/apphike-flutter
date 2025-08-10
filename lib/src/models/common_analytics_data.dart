import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apphike/src/config/constants.dart';
import 'package:apphike/src/models/device_info.dart';
import 'package:apphike/src/services/device_info_service.dart';

/// Common analytics fields shared across event, screen and session analytics
class CommonAnalyticsData {
  /// Optional unique identifier for the record (event/session/etc.)
  final String? id;

  /// Current session id
  final String? sessionId;

  /// Application package name / bundle identifier
  final String appId;

  /// Internal user id
  final String userId;

  /// Optional user-provided identifier
  final String? userIdentifier;

  /// App version
  final String appVersion;

  /// Platform name (iOS/Android/etc.)
  final String? platform;

  /// Device model name
  final String? deviceModel;

  /// Device OS version
  final String? deviceOsVersion;

  const CommonAnalyticsData({
    this.id,
    this.sessionId,
    required this.appId,
    required this.userId,
    this.userIdentifier,
    required this.appVersion,
    this.platform,
    this.deviceModel,
    this.deviceOsVersion,
  });

  /// Build a CommonAnalyticsData by reading from the environment (prefs, device, package info).
  /// Note: This method does not create or persist identifiers; it only reads existing values.
  static Future<CommonAnalyticsData> fromEnvironment({
    String? id,
    String? userIdentifier,
    SharedPreferences? prefs,
    PackageInfo? packageInfo,
    DeviceInfo? deviceInfo,
  }) async {
    final SharedPreferences p = prefs ?? await SharedPreferences.getInstance();
    final PackageInfo pkg = packageInfo ?? await PackageInfo.fromPlatform();
    final DeviceInfo di = deviceInfo ?? await DeviceInfoService.getDeviceInfo();

    final String? sessionId = p.getString(ApphikeConstants.prefKeySessionId);
    final String userId = p.getString(ApphikeConstants.prefKeyUserId) ?? '';

    return CommonAnalyticsData(
      id: id,
      sessionId: sessionId,
      appId: pkg.packageName,
      userId: userId,
      userIdentifier: userIdentifier,
      appVersion: pkg.version,
      platform: di.deviceOS,
      deviceModel: di.deviceName,
      deviceOsVersion: di.deviceOSVersion,
    );
  }

  /// Convert to the common payload map used by APIs
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      'app_id': appId,
      'user_id': userId,
      if (userIdentifier != null && userIdentifier!.isNotEmpty)
        'user_identifier': userIdentifier,
      if (platform != null) 'platform': platform,
      'app_version': appVersion,
      if (deviceModel != null) 'device_model': deviceModel,
      if (deviceOsVersion != null) 'device_os_version': deviceOsVersion,
    };
    return map;
  }
}
