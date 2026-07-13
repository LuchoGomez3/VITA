import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Page transition that fades the destination route into view.
class FadePage extends CustomTransitionPage<void> {
  /// Creates a page with a fade transition.
  FadePage({
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
    return FadeTransition(
      opacity: animation.drive(CurveTween(curve: Curves.easeOut)),
      child: child,
    );
  }
}
