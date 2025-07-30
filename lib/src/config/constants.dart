/// Constants used throughout the apphike package
class ApphikeConstants {
  /// apphike API base URL
  static const String apiBaseUrl =
      "https://apphike-dev-backend.neloy-nr2.workers.dev";

  /// SharedPreferences keys
  static const String prefKeyUserId = 'apphike_user_id';
  static const String prefKeySessionId = 'apphike_session_id';
  static const String prefKeySessionStartTime = 'apphike_session_start_time';
  static const String prefKeySessionEndTime = 'apphike_session_end_time';
  static const String prefKeySessionDurationGap =
      'apphike_session_duration_gap';
  static const String prefKeyScreenData = 'apphike_screen_data';

  /// Communication types
  static const List<String> allowedCommunicationTypes = [
    "feedback",
    "bug",
    "feature_request",
    "contact",
  ];

  /// Analytics endpoints
  static const String endpointSessionTrack = "/analytics/sessions/track";
  static const String endpointScreenTrack = "/analytics/screens/track";
  static const String endpointEventTrack = "/analytics/events/track";
  static const String endpointReviewSubmit = "/user/submit/review";
  static const String endpointCommunicationSubmit =
      "/user/submit/communication";
}
