import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:apphike/src/config/constants.dart';
import 'package:apphike/src/services/common_analytics_service.dart';

/// Service for tracking application crashes and errors
class CrashAnalyticsService {
  /// Common analytics service instance
  final CommonAnalyticsService _commonService;

  /// Whether the service has been initialized
  bool _isInitialized = false;

  /// Private constructor for singleton
  CrashAnalyticsService._() : _commonService = CommonAnalyticsService.instance;

  /// Singleton instance
  static final CrashAnalyticsService _instance = CrashAnalyticsService._();

  /// Get singleton instance
  static CrashAnalyticsService get instance => _instance;

  /// Initialize the crash analytics service
  Future<void> initialize({
    required String apiKey,
    required String userIdentifier,
    String? baseUrl,
  }) async {
    if (_isInitialized) {
      debugPrint('CrashAnalyticsService already initialized');
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
      debugPrint('CrashAnalyticsService initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize CrashAnalyticsService: $e');
      rethrow;
    }
  }

  /// Track a crash or error
  Future<void> trackCrash({
    required String crashType,
    required String crashMessage,
    required String stackTrace,
    String? crashId,
  }) async {
    if (!_isInitialized || !_commonService.isInitialized) {
      debugPrint(
        'CrashAnalyticsService not initialized. Call initialize() first.',
      );
      return;
    }

    try {
      // Generate unique crash ID if not provided
      final id = crashId ?? const Uuid().v4();

      // Build common payload and add crash-specific data
      final Map<String, dynamic> data = {
        ..._commonService.buildCommonPayload(id: id),
        'crash_type': crashType,
        'crash_message': crashMessage,
        'stack_trace': stackTrace,
      };

      // Send crash data to API
      await _commonService.apiService.post(
        ApphikeConstants.endpointCrashTrack,
        _commonService.apiKey,
        data,
      );

      debugPrint('Crash tracked successfully: $crashType');
    } catch (e) {
      debugPrint('Failed to track crash: $e');
      // Don't throw here to avoid causing additional crashes
    }
  }

  /// Track a Flutter error
  Future<void> trackFlutterError(FlutterErrorDetails errorDetails) async {
    final stackTrace = errorDetails.toString();
    final exception = errorDetails.toStringShort();
    final library = errorDetails.library ?? 'Unknown';

    await trackCrash(
      crashType: 'flutter_error',
      crashMessage: '$exception in $library',
      stackTrace: stackTrace,
    );
  }

  /// Track a platform error (Dart uncaught exception)
  Future<void> trackPlatformError(Object error, StackTrace stackTrace) async {
    await trackCrash(
      crashType: 'platform_error',
      crashMessage: error.toString(),
      stackTrace: stackTrace.toString(),
    );
  }

  /// Track a custom error
  Future<void> trackCustomError({
    required String errorMessage,
    String? stackTrace,
    String? errorType,
  }) async {
    await trackCrash(
      crashType: errorType ?? 'custom_error',
      crashMessage: errorMessage,
      stackTrace: stackTrace ?? 'No stack trace available',
    );
  }

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;
}
