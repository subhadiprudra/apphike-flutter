import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:apphike/src/config/constants.dart';
import 'package:apphike/src/models/device_info.dart';
import 'package:apphike/src/services/api_service.dart';
import 'package:apphike/src/services/device_info_service.dart';

/// Service for tracking custom events
class EventAnalyticsService {
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
  EventAnalyticsService._();

  /// Singleton instance
  static final EventAnalyticsService _instance = EventAnalyticsService._();

  /// Get singleton instance
  static EventAnalyticsService get instance => _instance;

  /// Initialize the event analytics service
  Future<void> initialize({
    required String apiKey,
    required String userIdentifier,
    String? baseUrl,
  }) async {
    if (_isInitialized) {
      debugPrint('EventAnalyticsService already initialized');
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

      // Get current session ID (from session analytics service)
      _sessionId =
          _prefs.getString(ApphikeConstants.prefKeySessionId) ??
          const Uuid().v4();

      _isInitialized = true;
      debugPrint('EventAnalyticsService initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize EventAnalyticsService: $e');
      rethrow;
    }
  }

  /// Track a custom event
  Future<void> trackEvent({
    required String eventName,
    String? eventData,
  }) async {
    if (!_isInitialized) {
      debugPrint(
        'EventAnalyticsService not initialized. Call initialize() first.',
      );
      return;
    }

    try {
      // Generate unique event ID
      final eventId = const Uuid().v4();

      // Prepare event data
      final Map<String, dynamic> data = {
        'id': eventId,
        'session_id': _sessionId,
        'app_id': _appPackageName,
        'user_id': _userId,
        'user_identifier': _userIdentifier,
        'platform': _deviceInfo.deviceOS,
        'app_version': _appVersion,
        'device_model': _deviceInfo.deviceName,
        'device_os_version': _deviceInfo.deviceOSVersion,
        'event_name': eventName,
      };

      // Add event_data if provided
      if (eventData != null) {
        data['event_data'] = eventData;
      }

      // Send event to API
      await _apiService.post(
        ApphikeConstants.endpointEventTrack,
        _apiKey,
        data,
      );

      debugPrint('Event tracked successfully: $eventName');
    } catch (e) {
      debugPrint('Failed to track event: $e');
      // Optionally, you could store failed events for retry later
    }
  }

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Get current user ID
  String? get userId => _isInitialized ? _userId : null;

  /// Get current session ID
  String? get sessionId => _isInitialized ? _sessionId : null;
}
