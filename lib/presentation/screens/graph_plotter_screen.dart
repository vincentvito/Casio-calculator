import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../painters/graph_painter.dart';
import '../providers/graph_plotter_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/feedback_provider.dart';
import '../widgets/common/neumorphic_container.dart';
import '../../core/enums/neumorphic_style.dart';

/// Graph plotting screen for visualizing mathematical functions
class GraphPlotterScreen extends StatefulWidget {
  const GraphPlotterScreen({super.key});

  @override
  State<GraphPlotterScreen> createState() => _GraphPlotterScreenState();
}

class _GraphPlotterScreenState extends State<GraphPlotterScreen> {
  late TextEditingController _expressionController;
  final FocusNode _focusNode = FocusNode();

  // Gesture state
  Offset? _lastPanPosition;
  double? _initialPinchDistance;

  @override
  void initState() {
    super.initState();
    final provider = context.read<GraphPlotterProvider>();
    _expressionController = TextEditingController(text: provider.expression);
  }

  @override
  void dispose() {
    _expressionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onPlot() {
    final provider = context.read<GraphPlotterProvider>();
    provider.updateExpression(_expressionController.text);
    if (provider.validateExpression()) {
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;
    final provider = context.watch<GraphPlotterProvider>();

    return Column(
      children: [
        // Expression input
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: _buildExpressionInput(theme, provider),
        ),

        // Graph canvas
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: _buildGraphCanvas(theme, provider),
          ),
        ),

        // Control buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: _buildControlButtons(theme, provider),
        ),

        // Coordinate display
        if (provider.touchPoint != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildCoordinateDisplay(theme, provider),
          ),
      ],
    );
  }

  Widget _buildExpressionInput(dynamic theme, GraphPlotterProvider provider) {
    return NeumorphicContainer(
      style: NeumorphicStyle.concave,
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(
            'y = ',
            style: TextStyle(
              color: theme.displayTextDim,
              fontSize: 18,
              fontFamily: 'JetBrains Mono',
            ),
          ),
          Expanded(
            child: TextField(
              controller: _expressionController,
              focusNode: _focusNode,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontFamily: 'JetBrains Mono',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'sin(x)',
                hintStyle: TextStyle(
                  color: Colors.black.withValues(alpha: 0.3),
                  fontSize: 18,
                  fontFamily: 'JetBrains Mono',
                ),
              ),
              onSubmitted: (_) => _onPlot(),
            ),
          ),
          GestureDetector(
            onTap: () {
              context.read<FeedbackProvider>().lightTap();
              _onPlot();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.accentColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.play_arrow,
                color: theme.textOnAccent,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphCanvas(dynamic theme, GraphPlotterProvider provider) {
    return NeumorphicContainer(
      style: NeumorphicStyle.concave,
      borderRadius: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          color: theme.displayBackground,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Recalculate points when size is available
              WidgetsBinding.instance.addPostFrameCallback((_) {
                provider.recalculatePoints(
                  Size(constraints.maxWidth, constraints.maxHeight),
                );
              });

              return GestureDetector(
                onScaleStart: (details) {
                  _lastPanPosition = details.focalPoint;
                  _initialPinchDistance = null;
                },
                onScaleUpdate: (details) {
                  final canvasSize =
                      Size(constraints.maxWidth, constraints.maxHeight);

                  if (details.pointerCount == 2) {
                    // Pinch zoom
                    _initialPinchDistance ??= 1.0;
                    provider.pinchZoom(details.scale);
                    provider.recalculatePoints(canvasSize);
                  } else if (details.pointerCount == 1 &&
                      _lastPanPosition != null) {
                    // Pan
                    final delta = details.focalPoint - _lastPanPosition!;
                    _lastPanPosition = details.focalPoint;

                    // Convert screen delta to math delta
                    final xRange = provider.xMax - provider.xMin;
                    final yRange = provider.yMax - provider.yMin;
                    final dxMath = -delta.dx / canvasSize.width * xRange;
                    final dyMath = delta.dy / canvasSize.height * yRange;

                    provider.pan(dxMath, dyMath);
                    provider.recalculatePoints(canvasSize);
                  }
                },
                onScaleEnd: (_) {
                  _lastPanPosition = null;
                  _initialPinchDistance = null;
                },
                onTapDown: (details) {
                  final canvasSize =
                      Size(constraints.maxWidth, constraints.maxHeight);
                  provider.setTouchPoint(details.localPosition);

                  // Update coordinate display
                  provider.recalculatePoints(canvasSize);
                },
                onTapUp: (_) {
                  // Keep touch point visible for a moment
                },
                onDoubleTap: () {
                  context.read<FeedbackProvider>().lightTap();
                  provider.resetView();
                  provider.recalculatePoints(
                    Size(constraints.maxWidth, constraints.maxHeight),
                  );
                },
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: GraphPainter(
                        points: provider.points,
                        xMin: provider.xMin,
                        xMax: provider.xMax,
                        yMin: provider.yMin,
                        yMax: provider.yMax,
                        gridColor: theme.displayTextDim.withOpacity(0.3),
                        axisColor: theme.displayText,
                        curveColor: theme.accentColor,
                        labelColor: theme.displayText,
                        touchPoint: provider.touchPoint,
                      ),
                    ),
                    // Error overlay
                    if (provider.isError)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.errorColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            provider.errorMessage,
                            style: TextStyle(
                              color: theme.textOnAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons(dynamic theme, GraphPlotterProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ControlButton(
          icon: Icons.add,
          onTap: () {
            context.read<FeedbackProvider>().lightTap();
            provider.zoomIn();
          },
          theme: theme,
        ),
        const SizedBox(width: 12),
        _ControlButton(
          icon: Icons.remove,
          onTap: () {
            context.read<FeedbackProvider>().lightTap();
            provider.zoomOut();
          },
          theme: theme,
        ),
        const SizedBox(width: 12),
        _ControlButton(
          icon: Icons.refresh,
          onTap: () {
            context.read<FeedbackProvider>().lightTap();
            provider.resetView();
          },
          theme: theme,
        ),
        const SizedBox(width: 24),
        _QuickExpressionChip(
          label: 'x²',
          onTap: () {
            _expressionController.text = 'x^2';
            _onPlot();
          },
          theme: theme,
        ),
        const SizedBox(width: 8),
        _QuickExpressionChip(
          label: 'sin',
          onTap: () {
            _expressionController.text = 'sin(x)';
            _onPlot();
          },
          theme: theme,
        ),
        const SizedBox(width: 8),
        _QuickExpressionChip(
          label: 'cos',
          onTap: () {
            _expressionController.text = 'cos(x)';
            _onPlot();
          },
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildCoordinateDisplay(dynamic theme, GraphPlotterProvider provider) {
    if (provider.touchPoint == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Tap graph to see coordinates',
        style: TextStyle(
          color: theme.textSecondary,
          fontSize: 12,
          fontFamily: 'JetBrains Mono',
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final dynamic theme;

  const _ControlButton({
    required this.icon,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        style: NeumorphicStyle.convex,
        borderRadius: 12,
        width: 44,
        height: 44,
        child: Center(
          child: Icon(
            icon,
            color: theme.textPrimary,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _QuickExpressionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final dynamic theme;

  const _QuickExpressionChip({
    required this.label,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<FeedbackProvider>().lightTap();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
