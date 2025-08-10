import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:apphike/src/config/constants.dart';
import 'package:apphike/src/models/device_info.dart';
import 'package:apphike/src/services/api_service.dart';
import 'package:apphike/src/services/device_info_service.dart';

/// Service for managing common analytics data across all analytics services
class CommonAnalyticsService {
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

  /// Application package name
  late final String _appPackageName;

  /// Internal user ID
  late String _userId;

  /// Current session ID
  late String _sessionId;

  /// Whether the service has been initialized
  bool _isInitialized = false;

  /// Private constructor for singleton
  CommonAnalyticsService._();

  /// Singleton instance
  static final CommonAnalyticsService _instance = CommonAnalyticsService._();

  /// Get singleton instance
  static CommonAnalyticsService get instance => _instance;

  /// Initialize the common analytics service
  Future<void> initialize({
    required String apiKey,
    required String userIdentifier,
    String? baseUrl,
  }) async {
    if (_isInitialized) {
      debugPrint('CommonAnalyticsService already initialized');
      return;
    }

    try {
      // Initialize shared preferences
      _prefs = await SharedPreferences.getInstance();

      // Store API key and user identifier
      _apiKey = apiKey;
      _userIdentifier = userIdentifier;

      // Initialize API service
      _apiService = ApiService(baseUrl: baseUrl ?? ApphikeConstants.apiBaseUrl);

      // Get device information
      _deviceInfo = await DeviceInfoService.getDeviceInfo();

      // Get application version and package name
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = packageInfo.version;
      _appPackageName = packageInfo.packageName;

      // Get or create user ID
      _userId =
          _prefs.getString(ApphikeConstants.prefKeyUserId) ?? const Uuid().v4();
      await _prefs.setString(ApphikeConstants.prefKeyUserId, _userId);

      // Get current session ID
      _sessionId = _prefs.getString(ApphikeConstants.prefKeySessionId) ?? '';

      _isInitialized = true;
      debugPrint('CommonAnalyticsService initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize CommonAnalyticsService: $e');
      rethrow;
    }
  }

  /// Update session ID (called by session analytics service)
  void updateSessionId(String sessionId) {
    _sessionId = sessionId;
  }

  /// Build common analytics payload map
  Map<String, dynamic> buildCommonPayload({String? id}) {
    if (!_isInitialized) {
      throw Exception('CommonAnalyticsService not initialized');
    }

    final map = <String, dynamic>{
      if (id != null) 'id': id,
      if (_sessionId.isNotEmpty) 'session_id': _sessionId,
      'app_id': _appPackageName,
      'user_id': _userId,
      if (_userIdentifier.isNotEmpty) 'user_identifier': _userIdentifier,
      if (_deviceInfo.deviceOS != null) 'platform': _deviceInfo.deviceOS,
      'app_version': _appVersion,
      if (_deviceInfo.deviceName != null)
        'device_model': _deviceInfo.deviceName,
      if (_deviceInfo.deviceOSVersion != null)
        'device_os_version': _deviceInfo.deviceOSVersion,
    };
    return map;
  }

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Get API service
  ApiService get apiService => _apiService;

  /// Get API key
  String get apiKey => _apiKey;

  /// Get shared preferences
  SharedPreferences get prefs => _prefs;

  /// Get device info
  DeviceInfo get deviceInfo => _deviceInfo;

  /// Get user ID
  String get userId => _userId;

  /// Get user identifier
  String get userIdentifier => _userIdentifier;

  /// Get app version
  String get appVersion => _appVersion;

  /// Get app package name
  String get appPackageName => _appPackageName;

  /// Get session ID
  String get sessionId => _sessionId;
}
