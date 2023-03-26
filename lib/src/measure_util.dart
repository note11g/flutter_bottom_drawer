import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

double measureWidgetHeight(Widget widget, {required BuildContext context}) {
  final window = WidgetsBinding.instance.window;

  final renderBoundary = RenderRepaintBoundary();
  final renderView = _CustomRenderView(
    window: window,
    configuration: ViewConfiguration(
        size: window.physicalSize, devicePixelRatio: window.devicePixelRatio),
    child: renderBoundary,
  );

  final pipelineOwner = PipelineOwner()..rootNode = renderView;
  renderView.prepareInitialFrame();

  final buildOwner = BuildOwner(focusManager: FocusManager());
  final renderToWidget = RenderObjectToWidgetAdapter(
    container: renderBoundary,
    child: Theme(
        data: Theme.of(context),
        child: Directionality(textDirection: TextDirection.ltr, child: widget)),
  ).attachToRenderTree(buildOwner);

  buildOwner
    ..buildScope(renderToWidget)
    ..finalizeTree();

  pipelineOwner
    ..flushLayout()
    ..flushCompositingBits()
    ..flushPaint();

  final width = MediaQuery.of(context).size.width;
  final constraints =
      BoxConstraints(maxWidth: width, maxHeight: double.infinity);

  renderView.layout(constraints);
  renderToWidget.renderObject.layout(constraints);

  return renderToWidget.renderObject.paintBounds.size.height;
}

class _CustomRenderView extends RenderView {
  _CustomRenderView({
    super.child,
    required super.configuration,
    required super.window,
  });

  @override
  void debugAssertDoesMeetConstraints() {}
}
