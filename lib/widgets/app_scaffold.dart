import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A light-weight shared scaffold to centralize visual chrome
/// (AppBar, padding, background) so screen changes propagate
/// identically on both Android and iOS emulators.
class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final bool showAppBar;

  const AppScaffold({
    Key? key,
    this.title,
    required this.body,
    this.actions,
    this.showAppBar = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: showAppBar
          ? AppBar(
              title: title != null ? Text(title!) : null,
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              actions: actions,
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: body,
        ),
      ),
    );
  }
}
