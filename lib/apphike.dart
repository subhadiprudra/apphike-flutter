import 'dart:ui';

import 'package:apphike/src/apphike_core.dart';
import 'package:flutter/material.dart';

// Export services for advanced usage
export 'package:apphike/src/services/event_analytics_service.dart';
export 'package:apphike/src/apphike_core.dart';

/// Root widget for FeedbackNest integration
///
/// This widget initializes FeedbackNest and handles app lifecycle changes
class Apphike extends StatefulWidget {
  /// API key for FeedbackNest services
  final String apiKey;

  /// Child widget
  final Widget child;

  /// Optional user identifier
  final String? userIdentifier;

  /// Optional additional properties
  final Map<String, dynamic>? props;

  /// Creates a FeedbackNest widget
  const Apphike({
    super.key,
    required this.apiKey,
    required this.child,
    this.userIdentifier,
    this.props,
  });

  @override
  State<Apphike> createState() => _FeedbackNestState();

  // Static methods for easy access to Apphike functionality
  static void onScreenPushed(String screenName) {
    ApphikeCore.onScreenPushed(screenName);
  }

  static void onScreenPopped(String screenName) {
    ApphikeCore.onScreenPopped(screenName);
  }

  static Future<void> trackEvent({
    required String eventName,
    String? eventData,
  }) async {
    await ApphikeCore.trackEvent(eventName: eventName, eventData: eventData);
  }
}

class _FeedbackNestState extends State<Apphike>
    with WidgetsBindingObserver, RouteAware {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void initState() {
    super.initState();
    ApphikeCore.init(
      widget.apiKey,
      userIdentifier: widget.userIdentifier ?? "",
      props: widget.props,
    );

    // Add observer to track app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // Set up error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('FlutterError caught: ${details.exception}');
      debugPrint('🔴 1Flutter Error Caught:');
      debugPrint('  Exception: ${details.exception}');
      debugPrint('  Library: ${details.library}');
      debugPrint('  Context: ${details.context}');
      debugPrint('  Stack trace: ${details.stack}');
      debugPrint('  String: ${details.toDiagnosticsNode()}');
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      // Log the error or send it to a crash reporting service
      print('Unhandled Platform Error: $error\n$stack');
      return true; // Return true to indicate the error is handled and prevent app termination
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute<void>? currentRoute = ModalRoute.of(context);
    if (currentRoute != null) {
      debugPrint('Apphike subscribed to route: ${currentRoute.settings.name}');
    }
  }

  @override
  void dispose() {
    debugPrint("FeedbackNest widget disposed");
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Forward app lifecycle changes to the FeedbackNest core
    ApphikeCore.onLifeCycleEventChange(state);
  }
}
