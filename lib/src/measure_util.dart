import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

double measureWidgetHeight(Widget widget, {required BuildContext context}) {
  final view = View.of(context);

  final renderBoundary = RenderRepaintBoundary();
  final renderView = _CustomRenderView(
    view: view,
    configuration: ViewConfiguration(
        size: view.physicalSize, devicePixelRatio: view.devicePixelRatio),
    child: renderBoundary,
  );

  final pipelineOwner = PipelineOwner()..rootNode = renderView;
  renderView.prepareInitialFrame();

  final buildOwner = BuildOwner(focusManager: FocusManager());
  final renderToWidget = RenderObjectToWidgetAdapter(
          container: renderBoundary,
          child: MediaQuery(
              data: MediaQueryData.fromView(view),
              child: Theme(
                  data: Theme.of(context),
                  child: Localizations.override(
                      context: context,
                      child: Directionality(
                          textDirection: TextDirection.ltr, child: widget)))))
      .attachToRenderTree(buildOwner);

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

  renderView.layout(constraints, parentUsesSize: true);
  renderToWidget.renderObject.layout(constraints, parentUsesSize: true);

  final measuredSize = renderToWidget.renderObject.paintBounds.size;

  final emptyRenderToWidget =
      RenderObjectToWidgetAdapter(container: renderBoundary);
  renderToWidget.update(emptyRenderToWidget);
  buildOwner.finalizeTree();

  return measuredSize.height;
}

class _CustomRenderView extends RenderView {
  _CustomRenderView({
    super.child,
    required super.configuration,
    required super.view,
  });

  @override
  void debugAssertDoesMeetConstraints() {}
}
