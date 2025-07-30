import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:apphike/src/config/constants.dart';
import 'package:apphike/src/models/device_info.dart';
import 'package:apphike/src/models/session_data.dart';
import 'package:apphike/src/services/api_service.dart';
import 'package:apphike/src/services/device_info_service.dart';

/// Service for handling session analytics
class SessionAnalyticsService {
  /// Shared preferences instance
  late final SharedPreferences _prefs;

  /// Device information
  late final DeviceInfo _deviceInfo;

  /// API service for making requests
  late final ApiService _apiService;

  /// API key
  late final String _apiKey;

  /// User-provided identifier
  late final String _userIdentifier;

  /// Application version
  late final String _appVersion;

  /// Internal user ID
  late String _userId;

  /// Session start time
  late final String _sessionStartTime;

  /// Duration of gaps in session (when app was paused)
  late int _sessionDurationGap;

  /// Previous session ID
  late final String _lastSessionId;

  /// Current session ID
  late final String _sessionId;

  /// Whether the service has been initialized
  bool _isInitialized = false;

  /// Time when the app was paused
  DateTime? _appPausedTime;

  /// Private constructor for singleton
  SessionAnalyticsService._();

  /// Singleton instance
  static final SessionAnalyticsService _instance = SessionAnalyticsService._();

  /// Get singleton instance
  static SessionAnalyticsService get instance => _instance;

  /// Initialize the session analytics service
  Future<void> initialize(
    String apiKey, {
    String userIdentifier = "",
    DeviceInfo? deviceInfo,
    ApiService? apiService,
  }) async {
    if (_isInitialized) return;

    _sessionStartTime = DateTime.now().toUtc().toIso8601String();
    _sessionDurationGap = 0;
    _prefs = await SharedPreferences.getInstance();
    _deviceInfo = deviceInfo ?? await _getDeviceInfo();
    _apiKey = apiKey;
    _userIdentifier = userIdentifier;
    _apiService =
        apiService ?? ApiService(baseUrl: ApphikeConstants.apiBaseUrl);

    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _appVersion = packageInfo.version;

    // Initialize session IDs
    _lastSessionId = _prefs.getString(ApphikeConstants.prefKeySessionId) ?? '';
    _sessionId = const Uuid().v4();
    _prefs.setString(ApphikeConstants.prefKeySessionId, _sessionId);

    // Initialize user ID
    _userId = _prefs.getString(ApphikeConstants.prefKeyUserId) ?? '';
    if (_userId.isEmpty) {
      _userId = Uuid().v4();
      _prefs.setString(ApphikeConstants.prefKeyUserId, _userId);
    }

    // Calculate last session duration
    int lastSessionDuration = _calculateLastSessionDuration();

    // Save session start time and reset gap
    _prefs.setString(
      ApphikeConstants.prefKeySessionStartTime,
      _sessionStartTime,
    );
    _prefs.setInt(ApphikeConstants.prefKeySessionDurationGap, 0);

    // Create session data
    final sessionData = SessionData(
      id: _sessionId,
      userId: _userId,
      userIdentifier: _userIdentifier,
      startTime: _sessionStartTime,
      appVersion: _appVersion,
      platform: _deviceInfo.deviceOS,
      deviceModel: _deviceInfo.deviceName,
      deviceOsVersion: _deviceInfo.deviceOSVersion,
      lastSessionId: _lastSessionId.isNotEmpty ? _lastSessionId : null,
      lastSessionDuration: lastSessionDuration > 0 ? lastSessionDuration : null,
    );

    // Track session start
    _apiService.post(
      ApphikeConstants.endpointSessionTrack,
      _apiKey,
      sessionData.toJson(),
    );

    _isInitialized = true;
  }

  /// Handle lifecycle events (app paused/resumed)
  void handleLifecycleChange(bool isPaused) {
    if (isPaused) {
      _appPausedTime = DateTime.now().toUtc();
      _prefs.setString(
        ApphikeConstants.prefKeySessionEndTime,
        _appPausedTime!.toIso8601String(),
      );
    } else if (_appPausedTime != null) {
      int gapDuration = DateTime.now()
          .toUtc()
          .difference(_appPausedTime!)
          .inSeconds;
      _sessionDurationGap += gapDuration;
      _prefs.setInt(
        ApphikeConstants.prefKeySessionDurationGap,
        _sessionDurationGap,
      );
      _appPausedTime = null;
    }
  }

  /// Calculate the duration of the previous session
  int _calculateLastSessionDuration() {
    int lastSessionDurationGap =
        _prefs.getInt(ApphikeConstants.prefKeySessionDurationGap) ?? 0;
    String lastSessionStartTime =
        _prefs.getString(ApphikeConstants.prefKeySessionStartTime) ?? '';
    String lastSessionEndTime =
        _prefs.getString(ApphikeConstants.prefKeySessionEndTime) ?? '';
    int lastSessionDuration = 0;

    if (lastSessionStartTime.isNotEmpty && lastSessionEndTime.isNotEmpty) {
      DateTime lastStartTime = DateTime.parse(lastSessionStartTime).toUtc();
      DateTime lastEndTime = DateTime.parse(lastSessionEndTime).toUtc();
      lastSessionDuration =
          lastEndTime.difference(lastStartTime).inSeconds -
          lastSessionDurationGap;
    }

    return lastSessionDuration;
  }

  /// Get device info (helper method)
  Future<DeviceInfo> _getDeviceInfo() async {
    try {
      return await DeviceInfoService.getDeviceInfo();
    } catch (e) {
      return const DeviceInfo(
        deviceName: 'Unknown Device',
        deviceOS: 'Unknown OS',
        deviceOSVersion: 'Unknown Version',
      );
    }
  }

  /// Check if the service has been initialized
  bool get isInitialized => _isInitialized;

  /// Get the current session ID
  String get sessionId => _sessionId;

  /// Get the user ID
  String get userId => _userId;

  /// Get the user identifier
  String get userIdentifier => _userIdentifier;

  /// Get the app version
  String get appVersion => _appVersion;

  /// Get the device info
  DeviceInfo get deviceInfo => _deviceInfo;

  /// Get the API key
  String get apiKey => _apiKey;

  /// Get the API service
  ApiService get apiService => _apiService;

  /// Get the shared preferences instance
  SharedPreferences get prefs => _prefs;
}
