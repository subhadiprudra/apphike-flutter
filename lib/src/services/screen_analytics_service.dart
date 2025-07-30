import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:apphike/src/config/constants.dart';
import 'package:apphike/src/services/session_analytics_service.dart';

/// Service for tracking screen analytics
class ScreenAnalyticsService {
  /// Map of screen data by screen name
  final Map<String, Map<String, dynamic>> _screenData = {};

  /// List of pending screen events (before initialization)
  final List<Map<String, dynamic>> _pendingScreenEvents = [];

  /// Whether the app is paused
  bool _isPaused = false;

  /// Session analytics service instance
  final SessionAnalyticsService _sessionService;

  /// Private constructor for singleton
  ScreenAnalyticsService._()
    : _sessionService = SessionAnalyticsService.instance;

  /// Singleton instance
  static final ScreenAnalyticsService _instance = ScreenAnalyticsService._();

  /// Get singleton instance
  static ScreenAnalyticsService get instance => _instance;

  /// Handle screen push event
  void onScreenPushed(String screenName) {
    if (!_sessionService.isInitialized) {
      // Queue the event for later processing
      _pendingScreenEvents.add({
        'type': 'push',
        'screenName': screenName,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      });
      return;
    }

    _screenData[screenName] = {
      "session_id": _sessionService.sessionId,
      "timestamp": DateTime.now().toUtc().toIso8601String(),
      "paused_duration": 0,
    };
  }

  /// Handle screen pop event
  void onScreenPopped(String screenName) {
    if (!_sessionService.isInitialized) {
      // Queue the event for later processing
      _pendingScreenEvents.add({
        'type': 'pop',
        'screenName': screenName,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      });
      return;
    }

    if (_screenData.containsKey(screenName)) {
      final screenInfo = _screenData[screenName];
      if (screenInfo != null) {
        final timestamp = DateTime.parse(screenInfo["timestamp"]);
        final totalDuration = DateTime.now()
            .toUtc()
            .difference(timestamp)
            .inSeconds;

        // Subtract the paused duration to get actual screen time
        final int pausedDuration = screenInfo["paused_duration"] ?? 0;
        final int duration = totalDuration - pausedDuration;

        screenInfo["duration"] = duration;

        // Push screen data to API
        _pushScreenData(screenName, screenInfo);
      }

      _screenData.remove(screenName);
    }
  }

  /// Handle app lifecycle changes (paused/resumed)
  void handleLifecycleChange(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _isPaused = true;

      // Initialize paused_duration for all active screens if not exists
      for (final screenName in _screenData.keys) {
        if (_screenData[screenName] != null) {
          _screenData[screenName]!["paused_duration"] =
              _screenData[screenName]!["paused_duration"] ?? 0;
        }
      }

      _saveScreenDataToPrefs();
    } else if (state == AppLifecycleState.resumed && _isPaused) {
      // The actual pause duration handling is done by the session service
      _isPaused = false;
    }
  }

  /// Save screen data to shared preferences
  Future<void> _saveScreenDataToPrefs() async {
    final String screenDataJson = jsonEncode(_screenData);
    await _sessionService.prefs.setString(
      ApphikeConstants.prefKeyScreenData,
      screenDataJson,
    );
  }

  /// Handle previous session's screen data
  Future<void> handlePreviousSessionScreenData() async {
    final String? screenDataJson = _sessionService.prefs.getString(
      ApphikeConstants.prefKeyScreenData,
    );

    if (screenDataJson != null && screenDataJson.isNotEmpty) {
      try {
        final Map<String, dynamic> previousScreenData = jsonDecode(
          screenDataJson,
        );

        // Push all previous session screen data
        for (final screenName in previousScreenData.keys) {
          final screenInfo = previousScreenData[screenName];
          if (screenInfo != null) {
            final timestamp = DateTime.parse(screenInfo["timestamp"]);
            final pausedDuration = screenInfo["paused_duration"] ?? 0;

            // Calculate duration from when screen was pushed until app was paused
            final String? lastEndTime = _sessionService.prefs.getString(
              ApphikeConstants.prefKeySessionEndTime,
            );
            if (lastEndTime != null && lastEndTime.isNotEmpty) {
              final DateTime endTime = DateTime.parse(lastEndTime);
              final totalDuration = endTime.difference(timestamp).inSeconds;
              final actualDuration = totalDuration - pausedDuration;

              screenInfo["duration"] = actualDuration;
              screenInfo["session_ended"] = true;

              _pushScreenData(screenName, screenInfo);
            }
          }
        }

        // Clear the saved screen data
        await _sessionService.prefs.remove(ApphikeConstants.prefKeyScreenData);
      } catch (e) {
        debugPrint("Error handling previous session screen data: $e");
        await _sessionService.prefs.remove(ApphikeConstants.prefKeyScreenData);
      }
    }
  }

  /// Push screen data to the API
  Future<void> _pushScreenData(
    String screenName,
    Map<String, dynamic> screenInfo,
  ) async {
    if (_sessionService.isInitialized) {
      final Map<String, dynamic> data = {
        "screen_name": screenName,
        "type": "end",
        "user_id": _sessionService.userId,
        "user_identifier": _sessionService.userIdentifier,
        "app_version": _sessionService.appVersion,
        "platform": _sessionService.deviceInfo.deviceOS,
        "device_model": _sessionService.deviceInfo.deviceName,
        "device_os_version": _sessionService.deviceInfo.deviceOSVersion,
        ...screenInfo,
      };

      try {
        await _sessionService.apiService.post(
          ApphikeConstants.endpointScreenTrack,
          _sessionService.apiKey,
          data,
        );
        debugPrint(
          "Screen data pushed for: $screenName, duration: ${screenInfo['duration']}s",
        );
      } catch (e) {
        debugPrint("Error pushing screen data: $e");
      }
    }
  }

  /// Replay pending screen events after initialization
  void replayPendingScreenEvents() {
    for (final event in _pendingScreenEvents) {
      final String eventType = event['type'];
      final String screenName = event['screenName'];
      final String timestamp = event['timestamp'];

      if (eventType == 'push') {
        _screenData[screenName] = {
          "session_id": _sessionService.sessionId,
          "timestamp": timestamp,
          "paused_duration": 0,
        };
      } else if (eventType == 'pop') {
        if (_screenData.containsKey(screenName)) {
          final screenInfo = _screenData[screenName];
          if (screenInfo != null) {
            final startTimestamp = DateTime.parse(screenInfo["timestamp"]);
            final endTimestamp = DateTime.parse(timestamp);
            final totalDuration = endTimestamp
                .difference(startTimestamp)
                .inSeconds;

            // Subtract the paused duration to get actual screen time
            final int pausedDuration = screenInfo["paused_duration"] ?? 0;
            final duration = totalDuration - pausedDuration;

            screenInfo["duration"] = duration;

            // Push screen data to API
            _pushScreenData(screenName, screenInfo);
          }

          _screenData.remove(screenName);
        }
      }
    }

    // Clear the pending events after replay
    _pendingScreenEvents.clear();
  }
}
