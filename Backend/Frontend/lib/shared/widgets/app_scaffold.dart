import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showAppBar;

  const AppScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.showAppBar = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              backgroundColor: const Color(0xFF3498db),
              foregroundColor: Colors.white,
            )
          : null,
      body: body,
    );
  }
}