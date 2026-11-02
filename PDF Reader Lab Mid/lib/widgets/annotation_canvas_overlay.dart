import 'dart:math';
import 'package:flutter/material.dart';

import '../models/reader_aux_models.dart';

class AnnotationCanvasOverlay114 extends StatefulWidget {
  final int pageNumber;
  final Size pageSize;
  final List<AnnotationItem114> pageAnnotations;
  final AnnotationKind114? activeTool;
  final bool eraserActive;
  final int activeColorHex;
  final ValueChanged<AnnotationItem114> onCreateAnnotation;
  final ValueChanged<String> onDeleteAnnotation;
  final ValueChanged<AnnotationItem114> onInspectNote;

  const AnnotationCanvasOverlay114({
    super.key,
    required this.pageNumber,
    required this.pageSize,
    required this.pageAnnotations,
    required this.activeTool,
    required this.eraserActive,
    required this.activeColorHex,
    required this.onCreateAnnotation,
    required this.onDeleteAnnotation,
    required this.onInspectNote,
  });

  @override
  State<AnnotationCanvasOverlay114> createState() =>
      _AnnotationCanvasOverlay114State();
}

class _AnnotationCanvasOverlay114State
    extends State<AnnotationCanvasOverlay114> {
  Offset? _dragStart;
  Offset? _dragCurrent;
  final List<Offset> _currentStroke = [];

  Offset _normalize(Offset local) {
    final dx = (local.dx / max(1.0, widget.pageSize.width)).clamp(0.0, 1.0);
    final dy = (local.dy / max(1.0, widget.pageSize.height)).clamp(0.0, 1.0);
    return Offset(dx, dy);
  }

  void _tryEraseAt(Offset local) {
    final n = _normalize(local);
    for (final ann in widget.pageAnnotations.reversed) {
      if (ann.normalizedRect != null) {
        final inflated = ann.normalizedRect!.inflate(0.03);
        if (inflated.contains(n)) {
          widget.onDeleteAnnotation(ann.id);
          return;
        }
      }
      for (final pt in ann.normalizedPoints) {
        if ((pt - n).distance < 0.045) {
          widget.onDeleteAnnotation(ann.id);
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final interactive = widget.activeTool != null || widget.eraserActive;

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !interactive,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                if (widget.eraserActive) {
                  _tryEraseAt(details.localPosition);
                  return;
                }
                final tool = widget.activeTool;
                if (tool == null) return;
                final norm = _normalize(details.localPosition);
                if (tool == AnnotationKind114.note) {
                  widget.onCreateAnnotation(
                    AnnotationItem114(
                      id: 'ann_${DateTime.now().microsecondsSinceEpoch}',
                      documentId: '',
                      pageNumber: widget.pageNumber,
                      kind: AnnotationKind114.note,
                      colorHex: widget.activeColorHex,
                      comment: 'Tap to view/edit note',
                      normalizedRect: Rect.fromLTWH(
                        (norm.dx - 0.025).clamp(0.02, 0.92),
                        (norm.dy - 0.025).clamp(0.02, 0.92),
                        0.05,
                        0.05,
                      ),
                      createdAt: DateTime.now(),
                    ),
                  );
                } else if (tool != AnnotationKind114.freehand) {
                  widget.onCreateAnnotation(
                    AnnotationItem114(
                      id: 'ann_${DateTime.now().microsecondsSinceEpoch}',
                      documentId: '',
                      pageNumber: widget.pageNumber,
                      kind: tool,
                      colorHex: widget.activeColorHex,
                      normalizedRect: Rect.fromLTWH(
                        (norm.dx - 0.22).clamp(0.04, 0.52),
                        (norm.dy - 0.015).clamp(0.02, 0.95),
                        0.44,
                        0.032,
                      ),
                      createdAt: DateTime.now(),
                    ),
                  );
                }
              },
              onPanStart: (details) {
                if (widget.eraserActive) {
                  _tryEraseAt(details.localPosition);
                  return;
                }
                final tool = widget.activeTool;
                if (tool == null) return;
                setState(() {
                  _dragStart = details.localPosition;
                  _dragCurrent = details.localPosition;
                  _currentStroke
                    ..clear()
                    ..add(_normalize(details.localPosition));
                });
              },
              onPanUpdate: (details) {
                if (widget.eraserActive) {
                  _tryEraseAt(details.localPosition);
                  return;
                }
                if (widget.activeTool == null) return;
                setState(() {
                  _dragCurrent = details.localPosition;
                  if (widget.activeTool == AnnotationKind114.freehand) {
                    _currentStroke.add(_normalize(details.localPosition));
                  }
                });
              },
              onPanEnd: (_) {
                final tool = widget.activeTool;
                if (tool == null || widget.eraserActive) return;

                if (tool == AnnotationKind114.freehand &&
                    _currentStroke.length >= 2) {
                  widget.onCreateAnnotation(
                    AnnotationItem114(
                      id: 'ann_${DateTime.now().microsecondsSinceEpoch}',
                      documentId: '',
                      pageNumber: widget.pageNumber,
                      kind: AnnotationKind114.freehand,
                      colorHex: widget.activeColorHex,
                      normalizedPoints: List<Offset>.from(_currentStroke),
                      createdAt: DateTime.now(),
                    ),
                  );
                } else if (_dragStart != null &&
                    _dragCurrent != null &&
                    tool != AnnotationKind114.note &&
                    tool != AnnotationKind114.freehand) {
                  final a = _normalize(_dragStart!);
                  final b = _normalize(_dragCurrent!);
                  final rect = Rect.fromPoints(a, b);
                  if (rect.width > 0.03) {
                    widget.onCreateAnnotation(
                      AnnotationItem114(
                        id: 'ann_${DateTime.now().microsecondsSinceEpoch}',
                        documentId: '',
                        pageNumber: widget.pageNumber,
                        kind: tool,
                        colorHex: widget.activeColorHex,
                        normalizedRect: Rect.fromLTWH(
                          rect.left,
                          rect.top,
                          rect.width,
                          max(rect.height, 0.028),
                        ),
                        createdAt: DateTime.now(),
                      ),
                    );
                  }
                }
                setState(() {
                  _dragStart = null;
                  _dragCurrent = null;
                  _currentStroke.clear();
                });
              },
              child: CustomPaint(
                painter: _AnnotationPainter114(
                  annotations: widget.pageAnnotations,
                  liveStroke: _currentStroke,
                  liveDragRect: (_dragStart != null &&
                          _dragCurrent != null &&
                          widget.activeTool != AnnotationKind114.freehand)
                      ? Rect.fromPoints(_dragStart!, _dragCurrent!)
                      : null,
                  activeColor: Color(widget.activeColorHex),
                ),
              ),
            ),
          ),
        ),
        // Render clickable sticky note pins
        for (final ann in widget.pageAnnotations.where(
          (a) => a.kind == AnnotationKind114.note && a.normalizedRect != null,
        ))
          Positioned(
            left: ann.normalizedRect!.left * widget.pageSize.width,
            top: ann.normalizedRect!.top * widget.pageSize.height,
            child: GestureDetector(
              onTap: () {
                if (widget.eraserActive) {
                  widget.onDeleteAnnotation(ann.id);
                } else {
                  widget.onInspectNote(ann);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Color(ann.colorHex),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sticky_note_2_rounded,
                  size: 15,
                  color: Color(0xFF0B1120),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AnnotationPainter114 extends CustomPainter {
  final List<AnnotationItem114> annotations;
  final List<Offset> liveStroke;
  final Rect? liveDragRect;
  final Color activeColor;

  const _AnnotationPainter114({
    required this.annotations,
    required this.liveStroke,
    required this.liveDragRect,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final ann in annotations) {
      final col = Color(ann.colorHex);
      switch (ann.kind) {
        case AnnotationKind114.highlight:
          if (ann.normalizedRect != null) {
            final r = _denorm(ann.normalizedRect!, size);
            canvas.drawRRect(
              RRect.fromRectAndRadius(r, const Radius.circular(3)),
              Paint()..color = col.withOpacity(0.36),
            );
          }
          break;
        case AnnotationKind114.underline:
          if (ann.normalizedRect != null) {
            final r = _denorm(ann.normalizedRect!, size);
            canvas.drawLine(
              Offset(r.left, r.bottom),
              Offset(r.right, r.bottom),
              Paint()
                ..color = col
                ..strokeWidth = 2.6,
            );
          }
          break;
        case AnnotationKind114.strikethrough:
          if (ann.normalizedRect != null) {
            final r = _denorm(ann.normalizedRect!, size);
            canvas.drawLine(
              Offset(r.left, r.center.dy),
              Offset(r.right, r.center.dy),
              Paint()
                ..color = col
                ..strokeWidth = 2.4,
            );
          }
          break;
        case AnnotationKind114.freehand:
          if (ann.normalizedPoints.length >= 2) {
            final path = Path()
              ..moveTo(
                ann.normalizedPoints.first.dx * size.width,
                ann.normalizedPoints.first.dy * size.height,
              );
            for (var i = 1; i < ann.normalizedPoints.length; i++) {
              path.lineTo(
                ann.normalizedPoints[i].dx * size.width,
                ann.normalizedPoints[i].dy * size.height,
              );
            }
            canvas.drawPath(
              path,
              Paint()
                ..color = col
                ..style = PaintingStyle.stroke
                ..strokeCap = StrokeCap.round
                ..strokeJoin = StrokeJoin.round
                ..strokeWidth = 2.8,
            );
          }
          break;
        case AnnotationKind114.note:
          break;
      }
    }

    if (liveStroke.length >= 2) {
      final path = Path()
        ..moveTo(liveStroke.first.dx * size.width, liveStroke.first.dy * size.height);
      for (var i = 1; i < liveStroke.length; i++) {
        path.lineTo(liveStroke[i].dx * size.width, liveStroke[i].dy * size.height);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = activeColor
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2.8,
      );
    }

    if (liveDragRect != null) {
      canvas.drawRect(
        liveDragRect!,
        Paint()..color = activeColor.withOpacity(0.28),
      );
    }
  }

  Rect _denorm(Rect nr, Size s) => Rect.fromLTWH(
        nr.left * s.width,
        nr.top * s.height,
        nr.width * s.width,
        nr.height * s.height,
      );

  @override
  bool shouldRepaint(covariant _AnnotationPainter114 oldDelegate) => true;
}
