import 'package:example/pane.dart';
import 'package:flutter/material.dart';
import 'package:split_pane/split_pane.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage(), debugShowCheckedModeBanner: false);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final SplitController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SplitController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainer,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            String getSecondarySizeText() {
              if (_controller.isAbsolute) {
                return '${_controller.position.toStringAsFixed(0)} dp';
              } else {
                return '${(_controller.position * 100).toStringAsFixed(0)}%';
              }
            }

            return SplitPane(
              controller: _controller,
              primary: Pane(),
              secondary: ClipRect(
                child: Pane(
                  child: Center(
                    child: Text(
                      getSecondarySizeText(),
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
