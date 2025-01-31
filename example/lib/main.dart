import 'package:example/pane.dart';
import 'package:example/rotate_button.dart';
import 'package:example/switch_pane_button.dart';
import 'package:example/theme.dart';
import 'package:flutter/material.dart';
import 'package:split_pane/split_pane.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
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
  Axis _direction = Axis.horizontal;
  PaneLocation _paneLocation = PaneLocation.trailing;

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return SplitPane(
              controller: _controller,
              direction: _direction,
              primaryPaneLocation: _paneLocation,
              primary: Pane(
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8.0,
                    children: [
                      RotateButton(onPressed: _onRotate),
                      SwitchPaneButton(
                        paneLocation: _paneLocation,
                        direction: _direction,
                        onPressed: _onSwitchPane,
                      ),
                    ],
                  ),
                ),
              ),
              secondary: ClipRect(
                child: Pane(
                  child: Center(
                    child: Text(sizeAsString),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onRotate() {
    setState(() => _direction =
        _direction == Axis.horizontal ? Axis.vertical : Axis.horizontal);
  }

  String get sizeAsString {
    final position = _controller.position;
    if (_controller.isAbsolute) {
      final dp = position.toStringAsFixed(0);
      return '$dp dp';
    } else {
      final percent = (position * 100).toStringAsFixed(0);
      return '$percent%';
    }
  }

  void _onSwitchPane() {
    setState(() {
      _paneLocation = switch (_paneLocation) {
        PaneLocation.leading => PaneLocation.trailing,
        PaneLocation.trailing => PaneLocation.leading,
      };
    });
  }
}
