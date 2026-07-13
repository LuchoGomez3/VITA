import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Page transition that enters from the left edge of the screen.
class BackwardPage extends CustomTransitionPage<void> {
  /// Creates a page with a backward slide transition.
  BackwardPage({
    required GoRouterState state,
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
  }) : super(
         key: state.pageKey,
         transitionsBuilder: _buildTransition,
       );

  static Widget _buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final position = animation.drive(
      Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
    );

    return SlideTransition(
      position: position,
      child: child,
    );
  }
}
