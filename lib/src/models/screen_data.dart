/// Model representing screen tracking data
class ScreenData {
  /// Session identifier this screen is part of
  final String sessionId;

  /// Screen name
  final String screenName;

  /// Type of event (start, end)
  final String type;

  /// User identifier
  final String userId;

  /// User-provided identifier (if any)
  final String? userIdentifier;

  /// Timestamp when the screen was opened or closed
  final String timestamp;

  /// Duration the screen was visible in seconds (only for end type)
  final int? duration;

  /// Whether the screen was part of a session that ended
  final bool? sessionEnded;

  /// Duration the app was paused while this screen was visible
  final int pausedDuration;

  /// Application version
  final String? appVersion;

  /// Device platform (iOS, Android, etc.)
  final String? platform;

  /// Device model
  final String? deviceModel;

  /// Device OS version
  final String? deviceOSVersion;

  /// Creates a new ScreenData instance
  const ScreenData({
    required this.sessionId,
    required this.screenName,
    required this.type,
    required this.userId,
    this.userIdentifier,
    required this.timestamp,
    this.duration,
    this.sessionEnded = false,
    this.pausedDuration = 0,
    this.appVersion,
    this.platform,
    this.deviceModel,
    this.deviceOSVersion,
  });

  /// Creates a ScreenData from a JSON map
  factory ScreenData.fromJson(Map<String, dynamic> json, String screenName) {
    return ScreenData(
      sessionId: json["session_id"],
      screenName: screenName,
      type: json["type"] ?? "end",
      userId: json["user_id"] ?? "",
      userIdentifier: json["user_identifier"],
      timestamp: json["timestamp"],
      duration: json["duration"],
      sessionEnded: json["session_ended"] ?? false,
      pausedDuration: json["paused_duration"] ?? 0,
      appVersion: json["app_version"],
      platform: json["platform"],
      deviceModel: json["device_model"],
      deviceOSVersion: json["device_os_version"],
    );
  }

  /// Converts the screen data to a JSON map
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "screen_name": screenName,
      "type": type,
      "user_id": userId,
      "user_identifier": userIdentifier,
      "session_id": sessionId,
      "timestamp": timestamp,
      "paused_duration": pausedDuration,
      "app_version": appVersion,
      "platform": platform,
      "device_model": deviceModel,
      "device_os_version": deviceOSVersion,
    };

    if (duration != null) {
      data["duration"] = duration;
    }

    if (sessionEnded == true) {
      data["session_ended"] = true;
    }

    return data;
  }
}
