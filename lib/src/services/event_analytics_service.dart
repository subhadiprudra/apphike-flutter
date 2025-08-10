import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:apphike/src/config/constants.dart';
import 'package:apphike/src/services/common_analytics_service.dart';

/// Service for tracking custom events
class EventAnalyticsService {
  /// Common analytics service instance
  final CommonAnalyticsService _commonService;

  /// Whether the service has been initialized
  bool _isInitialized = false;

  /// Private constructor for singleton
  EventAnalyticsService._() : _commonService = CommonAnalyticsService.instance;

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
      // Initialize common analytics service if not already done
      if (!_commonService.isInitialized) {
        await _commonService.initialize(
          apiKey: apiKey,
          userIdentifier: userIdentifier,
          baseUrl: baseUrl,
        );
      }

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
    if (!_isInitialized || !_commonService.isInitialized) {
      debugPrint(
        'EventAnalyticsService not initialized. Call initialize() first.',
      );
      return;
    }

    try {
      // Generate unique event ID
      final eventId = const Uuid().v4();

      // Build common payload and add event-specific data
      final Map<String, dynamic> data = {
        ..._commonService.buildCommonPayload(id: eventId),
        'event_name': eventName,
      };

      // Add event_data if provided
      if (eventData != null) {
        data['event_data'] = eventData;
      }

      // Send event to API
      await _commonService.apiService.post(
        ApphikeConstants.endpointEventTrack,
        _commonService.apiKey,
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
  String? get userId => _isInitialized ? _commonService.userId : null;

  /// Get current session ID
  String? get sessionId => _isInitialized ? _commonService.sessionId : null;
}
