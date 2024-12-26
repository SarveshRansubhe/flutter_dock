import 'package:flutter/material.dart';

/// DockNew of the reorderable [items].
class DockNew<T> extends StatefulWidget {
  const DockNew({
    super.key,
    this.items = const [],
  });

  /// Initial [T] items to put in this [DockNew].
  final List<T> items;

  @override
  State<DockNew<T>> createState() => _DockNewState<T>();
}

/// State of the [DockNew] used to manipulate the [_items].
class _DockNewState<T> extends State<DockNew<T>> with TickerProviderStateMixin {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  late List<AnimationController> _leftControllers;
  late List<AnimationController> _rightControllers;
  late List<Animation<Offset>> _offsetLeftAnimation;
  late List<Animation<Offset>> _offsetRightAnimation;

  @override
  void initState() {
    super.initState();
    _leftControllers = List.generate(
      5,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _rightControllers = List.generate(
      5,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _offsetLeftAnimation = List.generate(
      5,
      (index) => Tween<Offset>(
        begin: const Offset(0.0, 0.0),
        end: const Offset(-1.0, 0.0),
      ).animate(_leftControllers[index]),
    );

    _offsetRightAnimation = List.generate(
      5,
      (index) => Tween<Offset>(
        begin: const Offset(0.0, 0.0),
        end: const Offset(1.0, 0.0),
      ).animate(_rightControllers[index]),
    );
  }

  void _animatePosition(int index, int direction) {
    if (direction == -1) {
      _leftControllers[index].forward();
    } else {
      _rightControllers[index].forward();
    }
  }

  @override
  void dispose() {
    for (var element in _leftControllers) {
      element.dispose;
    }
    for (var element in _rightControllers) {
      element.dispose;
    }
    super.dispose();
  }

  Widget buildDockNewItem(T e) {
    int index = _items.indexOf(e);
    Widget child = SlideTransition(
      position: _offsetLeftAnimation[index],
      child: SlideTransition(
        position: _offsetRightAnimation[index],
        child: Container(
          constraints: const BoxConstraints(minWidth: 48),
          height: 48,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.primaries[e.hashCode % Colors.primaries.length],
          ),
          child: Center(child: Icon(e as IconData, color: Colors.white)),
        ),
      ),
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
        setState(() {
          draggingObj = null;
          distance = 0.0;
        });
      },
      onDragUpdate: (details) {
        distance += details.delta.dx;
        if (distance.abs() > 60 && draggingObj != null) {
          int direction = distance < 0 ? -1 : 1;
          _animatePosition(draggingObj! + direction, -1 * direction);
          _animatePosition(draggingObj!, direction);
        }
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
            return buildDockNewItem(e);
          },
        ).toList(),
      ),
    );
  }
}
