import 'package:apphike/src/services/common_analytics_service.dart';
import 'package:apphike/src/config/constants.dart';
import 'package:apphike/src/models/feedback.dart';

/// Service for handling user feedback functionality
class FeedbackService {
  /// Common analytics service instance
  final CommonAnalyticsService _commonService;

  /// Private constructor for singleton
  FeedbackService._() : _commonService = CommonAnalyticsService.instance;

  /// Singleton instance
  static final FeedbackService _instance = FeedbackService._();

  /// Get singleton instance
  static FeedbackService get instance => _instance;

  /// Submit a rating and optional review
  Future<void> submitRatingAndReview({
    required int rating,
    String? review,
  }) async {
    if (!_commonService.isInitialized) {
      throw Exception("FeedbackNest is not initialized. Call init() first.");
    }

    final feedback = RatingFeedback(
      rating: rating,
      review: review,
      userId: _commonService.userIdentifier,
      appVersion: _commonService.appVersion,
      platform: _commonService.deviceInfo.deviceOS,
      deviceModel: _commonService.deviceInfo.deviceName,
      deviceOsVersion: _commonService.deviceInfo.deviceOSVersion,
    );

    await _commonService.apiService.post(
      ApphikeConstants.endpointReviewSubmit,
      _commonService.apiKey,
      feedback.toJson(),
    );
  }

  /// Submit a communication (feedback, bug report, feature request, etc.)
  Future<void> submitCommunication({
    required String message,
    required String type,
    String? email,
    List<dynamic>? files,
  }) async {
    // Validate communication type
    final normalizedType = type.toLowerCase();
    if (!ApphikeConstants.allowedCommunicationTypes.contains(normalizedType)) {
      throw Exception(
        "Invalid communication type: $type. Allowed types are: ${ApphikeConstants.allowedCommunicationTypes.join(', ')}",
      );
    }

    if (!_commonService.isInitialized) {
      throw Exception("FeedbackNest is not initialized. Call init() first.");
    }

    final feedback = CommunicationFeedback(
      message: message,
      type: normalizedType,
      email: email,
      files: files,
      userId: _commonService.userIdentifier,
      appVersion: _commonService.appVersion,
      platform: _commonService.deviceInfo.deviceOS,
      deviceModel: _commonService.deviceInfo.deviceName,
      deviceOsVersion: _commonService.deviceInfo.deviceOSVersion,
    );

    // Convert files to CrossPlatformFile format
    final crossPlatformFiles = await feedback.getFormattedFiles();

    // Submit the communication
    await _commonService.apiService.postWithMultipart(
      endpoint: ApphikeConstants.endpointCommunicationSubmit,
      apiKey: _commonService.apiKey,
      fields: feedback.toFieldMap(),
      files: crossPlatformFiles.isNotEmpty ? crossPlatformFiles : null,
    );
  }
}
