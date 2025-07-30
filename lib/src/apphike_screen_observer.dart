import 'package:apphike/src/apphike_core.dart';
import 'package:flutter/material.dart';

/// A navigator observer that tracks screen navigation for analytics
class ApphikeScreenObserver extends NavigatorObserver {
  /// Called when a new route is pushed onto the navigator
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    try {
      final screenName = _getRouteName(route);
      debugPrint('🟢 Route Pushed: $screenName');
      ApphikeCore.onScreenPushed(screenName);

      if (previousRoute != null) {
        final previousScreenName = _getRouteName(previousRoute);
        debugPrint('Previous Route: $previousScreenName');
        ApphikeCore.onScreenPopped(previousScreenName);
      }
    } catch (e) {
      debugPrint('⚠️ Error in didPush: $e');
      ApphikeCore.onScreenPushed('ErrorRoute');
    }
  }

  /// Called when a route is popped from the navigator
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    try {
      final poppedScreen = _getRouteName(route);
      debugPrint('🔴 Route Popped: $poppedScreen');
      ApphikeCore.onScreenPopped(poppedScreen);

      if (previousRoute != null) {
        final currentScreenName = _getRouteName(previousRoute);
        debugPrint('New current Route: $currentScreenName');
        ApphikeCore.onScreenPushed(currentScreenName);
      }
    } catch (e) {
      debugPrint('⚠️ Error in didPop: $e');
      ApphikeCore.onScreenPopped('ErrorRoute');
    }
  }

  /// Called when a route is replaced by another route
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    try {
      final oldScreenName = _getRouteName(oldRoute);
      final newScreenName = _getRouteName(newRoute);
      debugPrint('🔁 Route Replaced: $oldScreenName → $newScreenName');

      // Track the old route as popped
      if (oldRoute != null) {
        ApphikeCore.onScreenPopped(oldScreenName);
      }

      // Track the new route as pushed
      if (newRoute != null) {
        ApphikeCore.onScreenPushed(newScreenName);
      }
    } catch (e) {
      debugPrint('⚠️ Error in didReplace: $e');
      ApphikeCore.onScreenPopped('ErrorRoute');
      ApphikeCore.onScreenPushed('ErrorRoute');
    }
  }

  /// Called when a route is removed from the navigator
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    try {
      final removedScreen = _getRouteName(route);
      debugPrint('🗑️ Route Removed: $removedScreen');
      ApphikeCore.onScreenPopped(removedScreen);
    } catch (e) {
      debugPrint('⚠️ Error in didRemove: $e');
      ApphikeCore.onScreenPopped('ErrorRoute');
    }
  }

  String _getRouteName(Route<dynamic>? route) {
    if (route == null) return 'null';

    // Prefer the explicitly set name
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) return name;

    // Fallback to route type if no name is provided
    try {
      // Try to extract a meaningful name from the route type
      final routeType = route.runtimeType.toString();

      // Handle common route types
      if (routeType.contains('MaterialPageRoute')) {
        return 'MaterialPageRoute';
      } else if (routeType.contains('CupertinoPageRoute')) {
        return 'CupertinoPageRoute';
      } else if (routeType.contains('PageRoute')) {
        return 'PageRoute';
      } else if (routeType.contains('ModalRoute')) {
        return 'ModalRoute';
      }

      // Generic fallback
      return routeType.isNotEmpty ? routeType : 'UnknownRoute';
    } catch (e) {
      // Ultimate fallback if even route type extraction fails
      debugPrint('⚠️ Warning: Could not determine route name: $e');
      debugPrint('''
  💡 Tip: Add RouteSettings to your routes for better tracking:
  MaterialPageRoute(
    builder: (context) => YourScreen(),
    settings: RouteSettings(name: '/your-screen-name'),
  )
  ''');
      return 'UnknownRoute';
    }
  }
}
