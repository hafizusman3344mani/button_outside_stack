import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Overflow Hit Test Example')),
        body: Center(
          child: OverflowExample(),
        ),
      ),
    );
  }
}

class OverflowExample extends StatelessWidget {
  OverflowExample({Key? key}) : super(key: key);

  final GlobalKey buttonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return OverflowWithHitTest(
      overflowKeys: [buttonKey],
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green,
          border: Border.all(color: Colors.red)
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(mainAxisSize: MainAxisSize.min
              ,
              children: [
                Container(
                  height: 200,
                  color: Colors.blue[100],
                  alignment: Alignment.center,
                  child: const Text(
                    'This is a sample text inside the box. The button overflows.',
                    textAlign: TextAlign.center,
                  ),
                ),
                const Text(
                  'This is a sample text inside the box. The button overflows.This is a sample text inside the box. The button overflows. This is a sample text inside the box. The button overflows. This is a sample text inside the box. The button overflows. This is a sample text inside the box. The button overflows.This is a sample text inside the box. The button overflows. This is a sample text inside the box. The button overflows. This is a sample text inside the box. The button overflows. This is a sample text inside the box. The button overflows.This is a sample text inside the box. The button overflows. This is a sample text inside the box. The button overflows. This is a sample text inside the box. The button overflows. This is a sample text inside the box. The button overflows.This is a sample text inside the box. The button overflows. This is a sample text inside the box. The button overflows. This is a sample text inside the box. The button overflows. This is a sample text inside the box. The button overflows.This is a sample text inside the box. The button overflows. This is a sample text inside the box. The button overflows. This is a sample text inside the box. The button overflows.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40,)
              ],
            ),

            Positioned(
              bottom: -30, // Overflowing the bottom edge
              left: 100,
              child: ElevatedButton(
                key: buttonKey, // Key for the overflowing widget
                onPressed: () {
                  debugPrint('Button pressed!');
                },
                child: const Text('Tap Me'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class OverflowWithHitTest extends SingleChildRenderObjectWidget {
  const OverflowWithHitTest({
    required this.overflowKeys,
    Widget? child,
    Key? key,
  }) : super(key: key, child: child);

  final List<GlobalKey> overflowKeys;

  @override
  _OverflowWithHitTestBox createRenderObject(BuildContext context) {
    return _OverflowWithHitTestBox(overflowKeys: overflowKeys);
  }

  @override
  void updateRenderObject(
      BuildContext context, _OverflowWithHitTestBox renderObject) {
    renderObject.overflowKeys = overflowKeys;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<List<GlobalKey>>('overflowKeys', overflowKeys));
  }
}

class _OverflowWithHitTestBox extends RenderProxyBoxWithHitTestBehavior {
  _OverflowWithHitTestBox({required List<GlobalKey> overflowKeys})
      : _overflowKeys = overflowKeys,
        super(behavior: HitTestBehavior.translucent);

  /// Global keys of overflow children
  List<GlobalKey> get overflowKeys => _overflowKeys;
  List<GlobalKey> _overflowKeys;

  set overflowKeys(List<GlobalKey> value) {
    var changed = false;

    if (value.length != _overflowKeys.length) {
      changed = true;
    } else {
      for (var ind = 0; ind < value.length; ind++) {
        if (value[ind] != _overflowKeys[ind]) {
          changed = true;
        }
      }
    }
    if (!changed) {
      return;
    }
    _overflowKeys = value;
    markNeedsPaint();
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (hitTestOverflowChildren(result, position: position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    bool hitTarget = false;
    if (size.contains(position)) {
      hitTarget =
          hitTestChildren(result, position: position) || hitTestSelf(position);
      if (hitTarget || behavior == HitTestBehavior.translucent)
        result.add(BoxHitTestEntry(this, position));
    }
    return hitTarget;
  }

  bool hitTestOverflowChildren(BoxHitTestResult result,
      {required Offset position}) {
    if (overflowKeys.length == 0) {
      return false;
    }
    var hitGlobalPosition = this.localToGlobal(position);
    for (var child in overflowKeys) {
      if (child.currentContext == null) {
        continue;
      }
      var renderObj = child.currentContext!.findRenderObject();
      if (renderObj == null || renderObj is! RenderBox) {
        continue;
      }

      var localPosition = renderObj.globalToLocal(hitGlobalPosition);
      if (renderObj.hitTest(result, position: localPosition)) {
        return true;
      }
    }
    return false;
  }
}