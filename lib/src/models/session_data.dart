/// Model representing a session
class SessionData {
  /// Unique session identifier
  final String id;

  /// User identifier
  final String userId;

  /// User-provided identifier (if any)
  final String? userIdentifier;

  /// Session start time in ISO 8601 format
  final String startTime;

  /// Application version
  final String appVersion;

  /// Device platform (iOS, Android, etc.)
  final String? platform;

  /// Device model
  final String? deviceModel;

  /// Device OS version
  final String? deviceOsVersion;

  /// Previous session ID (if any)
  final String? lastSessionId;

  /// Duration of the previous session in seconds
  final int? lastSessionDuration;

  /// Creates a new SessionData instance
  const SessionData({
    required this.id,
    required this.userId,
    this.userIdentifier,
    required this.startTime,
    required this.appVersion,
    this.platform,
    this.deviceModel,
    this.deviceOsVersion,
    this.lastSessionId,
    this.lastSessionDuration,
  });

  /// Converts the session data to a JSON map
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "id": id,
      "user_id": userId,
      "user_identifier": userIdentifier,
      "type": "start",
      "session_start_time": startTime,
      "app_version": appVersion,
      "platform": platform,
      "device_model": deviceModel,
      "device_os_version": deviceOsVersion,
    };

    if (lastSessionId != null &&
        lastSessionDuration != null &&
        lastSessionDuration! > 0) {
      data["last_session_id"] = lastSessionId;
      data["last_session_duration"] = lastSessionDuration;
    }

    return data;
  }
}
