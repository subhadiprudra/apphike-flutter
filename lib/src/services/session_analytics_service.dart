import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:apphike/src/config/constants.dart';
import 'package:apphike/src/models/device_info.dart';
import 'package:apphike/src/services/api_service.dart';
import 'package:apphike/src/services/common_analytics_service.dart';

/// Service for handling session analytics
class SessionAnalyticsService {
  /// Common analytics service instance
  final CommonAnalyticsService _commonService;

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
  SessionAnalyticsService._()
    : _commonService = CommonAnalyticsService.instance;

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

    // Initialize common analytics service first
    await _commonService.initialize(
      apiKey: apiKey,
      userIdentifier: userIdentifier,
    );

    _sessionStartTime = DateTime.now().toUtc().toIso8601String();
    _sessionDurationGap = 0;

    // Initialize session IDs
    _lastSessionId =
        _commonService.prefs.getString(ApphikeConstants.prefKeySessionId) ?? '';
    _sessionId = const Uuid().v4();
    await _commonService.prefs.setString(
      ApphikeConstants.prefKeySessionId,
      _sessionId,
    );

    // Update session ID in common service
    _commonService.updateSessionId(_sessionId);

    // Calculate last session duration
    int lastSessionDuration = _calculateLastSessionDuration();

    // Save session start time and reset gap
    await _commonService.prefs.setString(
      ApphikeConstants.prefKeySessionStartTime,
      _sessionStartTime,
    );
    await _commonService.prefs.setInt(
      ApphikeConstants.prefKeySessionDurationGap,
      0,
    );

    // Build session payload using common service
    final Map<String, dynamic> data = {
      ..._commonService.buildCommonPayload(id: _sessionId),
      "type": "start",
      "session_start_time": _sessionStartTime,
      if (_lastSessionId.isNotEmpty && lastSessionDuration > 0) ...{
        "last_session_id": _lastSessionId,
        "last_session_duration": lastSessionDuration,
      },
    };

    // Track session start
    _commonService.apiService.post(
      ApphikeConstants.endpointSessionTrack,
      _commonService.apiKey,
      data,
    );

    _isInitialized = true;
  }

  /// Handle lifecycle events (app paused/resumed)
  void handleLifecycleChange(bool isPaused) {
    if (isPaused) {
      _appPausedTime = DateTime.now().toUtc();
      _commonService.prefs.setString(
        ApphikeConstants.prefKeySessionEndTime,
        _appPausedTime!.toIso8601String(),
      );
    } else if (_appPausedTime != null) {
      int gapDuration = DateTime.now()
          .toUtc()
          .difference(_appPausedTime!)
          .inSeconds;
      _sessionDurationGap += gapDuration;
      _commonService.prefs.setInt(
        ApphikeConstants.prefKeySessionDurationGap,
        _sessionDurationGap,
      );
      _appPausedTime = null;
    }
  }

  /// Calculate the duration of the previous session
  int _calculateLastSessionDuration() {
    int lastSessionDurationGap =
        _commonService.prefs.getInt(
          ApphikeConstants.prefKeySessionDurationGap,
        ) ??
        0;
    String lastSessionStartTime =
        _commonService.prefs.getString(
          ApphikeConstants.prefKeySessionStartTime,
        ) ??
        '';
    String lastSessionEndTime =
        _commonService.prefs.getString(
          ApphikeConstants.prefKeySessionEndTime,
        ) ??
        '';
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

  /// Check if the service has been initialized
  bool get isInitialized => _isInitialized;

  /// Get the current session ID
  String get sessionId => _sessionId;

  /// Get the user ID
  String get userId => _commonService.userId;

  /// Get the user identifier
  String get userIdentifier => _commonService.userIdentifier;

  /// Get the app version
  String get appVersion => _commonService.appVersion;

  /// Get the device info
  DeviceInfo get deviceInfo => _commonService.deviceInfo;

  /// Get the API key
  String get apiKey => _commonService.apiKey;

  /// Get the API service
  ApiService get apiService => _commonService.apiService;

  /// Get the shared preferences instance
  SharedPreferences get prefs => _commonService.prefs;
}
