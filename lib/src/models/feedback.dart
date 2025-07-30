import 'package:apphike/src/services/api_service.dart';

/// Model representing user feedback data (rating and review)
class RatingFeedback {
  /// Rating value (usually 1-5)
  final int rating;

  /// Optional review text
  final String? review;

  /// User identifier
  final String? userId;

  /// Application version
  final String? appVersion;

  /// Device platform (iOS, Android, etc.)
  final String? platform;

  /// Device model
  final String? deviceModel;

  /// Device OS version
  final String? deviceOsVersion;

  /// Creates a new RatingFeedback instance
  const RatingFeedback({
    required this.rating,
    this.review,
    this.userId,
    this.appVersion,
    this.platform,
    this.deviceModel,
    this.deviceOsVersion,
  });

  /// Converts the rating feedback to a JSON map
  Map<String, dynamic> toJson() {
    return {
      "user_id": userId ?? "Unknown",
      "app_version": appVersion ?? "Unknown",
      "platform": platform ?? "Unknown",
      "device_model": deviceModel ?? "Unknown",
      "device_os_version": deviceOsVersion ?? "Unknown",
      "rating": rating,
      "review": review ?? "",
    };
  }
}

/// Model representing communication feedback data (bug, feature request, etc.)
class CommunicationFeedback {
  /// Message content
  final String message;

  /// Communication type (bug, feedback, feature_request, contact)
  final String type;

  /// Optional contact email
  final String? email;

  /// Optional file attachments
  final List<dynamic>? files;

  /// User identifier
  final String? userId;

  /// Application version
  final String? appVersion;

  /// Device platform (iOS, Android, etc.)
  final String? platform;

  /// Device model
  final String? deviceModel;

  /// Device OS version
  final String? deviceOsVersion;

  /// Creates a new CommunicationFeedback instance
  const CommunicationFeedback({
    required this.message,
    required this.type,
    this.email,
    this.files,
    this.userId,
    this.appVersion,
    this.platform,
    this.deviceModel,
    this.deviceOsVersion,
  });

  /// Converts communication feedback to field map for API requests
  Map<String, String> toFieldMap() {
    return {
      "user_id": userId ?? "Unknown",
      "app_version": appVersion ?? "Unknown",
      "platform": platform ?? "Unknown",
      "device_model": deviceModel ?? "Unknown",
      "device_os_version": deviceOsVersion ?? "Unknown",
      "message": message,
      "contact_email": email ?? "",
      "type": type,
    };
  }

  /// Convert files to CrossPlatformFile format
  Future<List<CrossPlatformFile>> getFormattedFiles() async {
    if (files == null || files!.isEmpty) {
      return [];
    }

    final List<CrossPlatformFile> crossPlatformFiles = <CrossPlatformFile>[];
    for (final file in files!) {
      final crossPlatformFile = await CrossPlatformFile.fromFile(file);
      crossPlatformFiles.add(crossPlatformFile);
    }

    return crossPlatformFiles;
  }
}
