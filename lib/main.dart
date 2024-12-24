import 'dart:math';
import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  Widget buildDockItem(T e) {
    Widget child = Container(
      constraints: const BoxConstraints(minWidth: 48),
      height: 48,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.primaries[e.hashCode % Colors.primaries.length],
      ),
      child: Center(child: Icon(e as IconData, color: Colors.white)),
    );

    double distance = 0.0;
    int? draggingObj;

    return Draggable(
      feedback: child,
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: child,
      ),
      onDragStarted: () {
        draggingObj = _items.indexWhere(
          (element) => element == e,
        );
      },
      onDragEnd: (details) {
        if (distance.abs() > 60) {
          int itemSkipped;
          if (distance < 0) {
            itemSkipped = (distance / 60).ceil();
          } else {
            itemSkipped = (distance / 60).floor();
          }
          if (draggingObj != null) {
            setState(() {
              T changedItem = _items.removeAt(draggingObj!);
              int newIndex = max(0, min(4, itemSkipped + draggingObj!));
              _items.insert(newIndex, changedItem);
            });
          }
        }
        draggingObj = null;
        distance = 0.0;
      },
      onDragUpdate: (details) {
        distance += details.delta.dx;
      },
      maxSimultaneousDrags: 1,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.map<Widget>(
          (T e) {
            return buildDockItem(e);
          },
        ).toList(),
      ),
    );
  }
}
