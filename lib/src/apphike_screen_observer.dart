import 'package:apphike/src/apphike_core.dart';
import 'package:flutter/material.dart';

/// A navigator observer that tracks screen navigation for analytics
class ApphikeScreenObserver extends NavigatorObserver {
  /// Called when a new route is pushed onto the navigator
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final screenName = _getRouteName(route);
    debugPrint('🟢 Route Pushed: $screenName');
    ApphikeCore.onScreenPushed(screenName);

    if (previousRoute != null) {
      debugPrint('Previous Route: ${_getRouteName(previousRoute)}');
      ApphikeCore.onScreenPopped(_getRouteName(previousRoute));
    }
  }

  /// Called when a route is popped from the navigator
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final poppedScreen = _getRouteName(route);
    debugPrint('🔴 Route Popped: $poppedScreen');
    ApphikeCore.onScreenPopped(poppedScreen);

    if (previousRoute != null) {
      debugPrint('New current Route: ${_getRouteName(previousRoute)}');
      ApphikeCore.onScreenPushed(_getRouteName(previousRoute));
    }
  }

  /// Called when a route is replaced by another route
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final oldScreenName = _getRouteName(oldRoute);
    final newScreenName = _getRouteName(newRoute);
    debugPrint('🔁 Route Replaced: $oldScreenName → $newScreenName');

    // Track the old route as popped
    if (oldRoute != null) {
      ApphikeCore.onScreenPopped(_getRouteName(oldRoute));
    }

    // Track the new route as pushed
    if (newRoute != null) {
      ApphikeCore.onScreenPushed(_getRouteName(newRoute));
    }
  }

  /// Called when a route is removed from the navigator
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final removedScreen = _getRouteName(route);
    debugPrint('🗑️ Route Removed: $removedScreen');
    ApphikeCore.onScreenPopped(removedScreen);
  }

  String _getRouteName(Route<dynamic>? route) {
    if (route == null) return 'null';

    // Prefer the explicitly set name
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) return name;

    throw Exception('''

  Add RouteSettings to your routes to get the name.
  For example, when using MaterialPageRoute:
  ```dart
  MaterialPageRoute(
    builder: (context) => TestScreen(),
    settings: RouteSettings(name: 'TestScreen'),
  ),
  add settings: RouteSettings(name: 'screen name') to your routes.

  ''');
  }
}
