import 'package:flutter/material.dart';

import 'package:apphike/src/services/screen_analytics_service.dart';
import 'package:apphike/src/services/session_analytics_service.dart';
import 'package:apphike/src/services/feedback_service.dart';
import 'package:apphike/src/services/event_analytics_service.dart';
import 'package:apphike/src/services/common_analytics_service.dart';
import 'package:apphike/src/services/crash_analytics_service.dart';

/// Main entry point for the FeedbackNest Core functionality
///
/// This class provides a facade to access all FeedbackNest services
class ApphikeCore {
  /// Initialize FeedbackNest with the required API key
  ///
  /// [apiKey] - The API key for the FeedbackNest service
  /// [userIdentifier] - Optional user identifier to associate with analytics
  /// [props] - Optional additional properties for initialization
  static Future<void> init(
    String apiKey, {
    String userIdentifier = "",
    Map<String, dynamic>? props,
  }) async {
    // Initialize the common analytics service first
    await CommonAnalyticsService.instance.initialize(
      apiKey: apiKey,
      userIdentifier: userIdentifier,
    );

    // Initialize the session analytics service
    await SessionAnalyticsService.instance.initialize(
      apiKey,
      userIdentifier: userIdentifier,
    );

    // Initialize the event analytics service
    await EventAnalyticsService.instance.initialize(
      apiKey: apiKey,
      userIdentifier: userIdentifier,
    );

    // Initialize the crash analytics service
    await CrashAnalyticsService.instance.initialize(
      apiKey: apiKey,
      userIdentifier: userIdentifier,
    );

    // Handle any previous session screen data
    await ScreenAnalyticsService.instance.handlePreviousSessionScreenData();

    // Replay any pending screen events
    ScreenAnalyticsService.instance.replayPendingScreenEvents();
  }

  /// Submit a rating and optional review
  static Future<void> submitRatingAndReview({
    required int rating,
    String? review,
  }) async {
    await FeedbackService.instance.submitRatingAndReview(
      rating: rating,
      review: review,
    );
  }

  /// Submit a communication (feedback, bug report, feature request, etc.)
  static Future<void> submitCommunication({
    required String message,
    required String type,
    String? email,
    List<dynamic>? files,
  }) async {
    await FeedbackService.instance.submitCommunication(
      message: message,
      type: type,
      email: email,
      files: files,
    );
  }

  /// Handle app lifecycle state changes
  static void onLifeCycleEventChange(AppLifecycleState state) {
    // Update session analytics
    SessionAnalyticsService.instance.handleLifecycleChange(
      state == AppLifecycleState.paused,
    );

    // Update screen analytics
    ScreenAnalyticsService.instance.handleLifecycleChange(state);
  }

  /// Track when a screen is pushed onto the navigation stack
  static void onScreenPushed(String screenName) {
    ScreenAnalyticsService.instance.onScreenPushed(screenName);
  }

  /// Track when a screen is popped from the navigation stack
  static void onScreenPopped(String screenName) {
    ScreenAnalyticsService.instance.onScreenPopped(screenName);
  }

  /// Track a custom event
  static Future<void> trackEvent({
    required String eventName,
    String? eventData,
  }) async {
    await EventAnalyticsService.instance.trackEvent(
      eventName: eventName,
      eventData: eventData,
    );
  }

  /// Track a crash or error
  static Future<void> trackCrash({
    required String crashType,
    required String crashMessage,
    required String stackTrace,
    String? crashId,
  }) async {
    await CrashAnalyticsService.instance.trackCrash(
      crashType: crashType,
      crashMessage: crashMessage,
      stackTrace: stackTrace,
      crashId: crashId,
    );
  }

  /// Track a Flutter error
  static Future<void> trackFlutterError(
    FlutterErrorDetails errorDetails,
  ) async {
    await CrashAnalyticsService.instance.trackFlutterError(errorDetails);
  }

  /// Track a platform error (Dart uncaught exception)
  static Future<void> trackPlatformError(
    Object error,
    StackTrace stackTrace,
  ) async {
    await CrashAnalyticsService.instance.trackPlatformError(error, stackTrace);
  }

  /// Track a custom error
  static Future<void> trackCustomError({
    required String errorMessage,
    String? stackTrace,
    String? errorType,
  }) async {
    await CrashAnalyticsService.instance.trackCustomError(
      errorMessage: errorMessage,
      stackTrace: stackTrace,
      errorType: errorType,
    );
  }
}
