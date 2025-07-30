import 'package:apphike/src/apphike_core.dart';
import 'package:flutter/material.dart';

/// A navigator observer that tracks screen navigation for analytics
class ApphikeScreenObserver extends NavigatorObserver {
  /// Called when a new route is pushed onto the navigator
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    try {
      final screenName = _getRouteName(route);
      if (_shouldTrackRoute(screenName)) {
        debugPrint('🟢 Route Pushed: $screenName');
        ApphikeCore.onScreenPushed(screenName);
      } else {
        debugPrint('⏭️ Skipping unknown route push: $screenName');
      }

      if (previousRoute != null) {
        final previousScreenName = _getRouteName(previousRoute);
        if (_shouldTrackRoute(previousScreenName)) {
          debugPrint('Previous Route: $previousScreenName');
          ApphikeCore.onScreenPopped(previousScreenName);
        } else {
          debugPrint(
            '⏭️ Skipping unknown previous route pop: $previousScreenName',
          );
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error in didPush: $e - Skipping route tracking');
    }
  }

  /// Called when a route is popped from the navigator
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    try {
      final poppedScreen = _getRouteName(route);
      if (_shouldTrackRoute(poppedScreen)) {
        debugPrint('🔴 Route Popped: $poppedScreen');
        ApphikeCore.onScreenPopped(poppedScreen);
      } else {
        debugPrint('⏭️ Skipping unknown route pop: $poppedScreen');
      }

      if (previousRoute != null) {
        final currentScreenName = _getRouteName(previousRoute);
        if (_shouldTrackRoute(currentScreenName)) {
          debugPrint('New current Route: $currentScreenName');
          ApphikeCore.onScreenPushed(currentScreenName);
        } else {
          debugPrint(
            '⏭️ Skipping unknown current route push: $currentScreenName',
          );
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error in didPop: $e - Skipping route tracking');
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
      if (oldRoute != null && _shouldTrackRoute(oldScreenName)) {
        ApphikeCore.onScreenPopped(oldScreenName);
      } else if (oldRoute != null) {
        debugPrint('⏭️ Skipping unknown old route pop: $oldScreenName');
      }

      // Track the new route as pushed
      if (newRoute != null && _shouldTrackRoute(newScreenName)) {
        ApphikeCore.onScreenPushed(newScreenName);
      } else if (newRoute != null) {
        debugPrint('⏭️ Skipping unknown new route push: $newScreenName');
      }
    } catch (e) {
      debugPrint('⚠️ Error in didReplace: $e - Skipping route tracking');
    }
  }

  /// Called when a route is removed from the navigator
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    try {
      final removedScreen = _getRouteName(route);
      if (_shouldTrackRoute(removedScreen)) {
        debugPrint('🗑️ Route Removed: $removedScreen');
        ApphikeCore.onScreenPopped(removedScreen);
      } else {
        debugPrint('⏭️ Skipping unknown route removal: $removedScreen');
      }
    } catch (e) {
      debugPrint('⚠️ Error in didRemove: $e - Skipping route tracking');
    }
  }

  /// Determines if a route should be tracked based on its name
  bool _shouldTrackRoute(String routeName) {
    // Skip tracking for unknown, error, or null routes
    if (routeName == 'UnknownRoute' ||
        routeName == 'ErrorRoute' ||
        routeName == 'null') {
      return false;
    }

    // Skip tracking for generic route types without specific names
    if (routeName == 'MaterialPageRoute' ||
        routeName == 'CupertinoPageRoute' ||
        routeName == 'PageRoute' ||
        routeName == 'ModalRoute') {
      return false;
    }

    return true;
  }

  String _getRouteName(Route<dynamic>? route) {
    if (route == null) return 'null';

    // Prefer the explicitly set name
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) return name;

    debugPrint('⚠️ Warning: Could not determine route name');
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
