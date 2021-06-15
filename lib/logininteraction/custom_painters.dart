import 'dart:ui';

import 'package:flutter/material.dart';

class SwipeToDragBg extends CustomPainter {
  final double arcHeight;

  final Animation<double> arcAnim;
  final Animation<double> arcHeightAnim;

  late Paint swipeArcPaint;

  SwipeToDragBg(this.arcAnim, this.arcHeightAnim, this.arcHeight)
      : super(repaint: arcAnim) {
    swipeArcPaint = Paint();
    swipeArcPaint.style = PaintingStyle.fill;
    swipeArcPaint.strokeWidth = 1;
    swipeArcPaint.isAntiAlias = true;
    swipeArcPaint.color = Colors.white;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawSwipeAbleArc(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void _drawSwipeAbleArc(Canvas canvas, Size size) {
    Path path = Path();

    path.moveTo(0, size.height);
    path.lineTo(0, size.height - arcAnim.value);
    path.cubicTo(
        0,
        size.height - arcAnim.value,
        size.width / 2,
        size.height - arcAnim.value - arcHeight - arcHeightAnim.value,
        size.width,
        size.height - arcAnim.value);
    path.moveTo(size.width, size.height - arcAnim.value);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, swipeArcPaint);
  }
}

class CurvePageSwitcher extends CustomPainter {
  final double arcHeight;
  final double archBottomOffset;
  final bool showLeftAsFirstPage;

  late Paint swipeArcPaint;

  final Animation<double> animation;

  CurvePageSwitcher(this.arcHeight, this.archBottomOffset,
      this.showLeftAsFirstPage, this.animation)
      : super(repaint: animation) {
    swipeArcPaint = Paint();
    swipeArcPaint.style = PaintingStyle.stroke;
    swipeArcPaint.isAntiAlias = true;
    swipeArcPaint.strokeWidth = 8;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawSwipeAbleArc(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CurvePageSwitcher oldDelegate) {
    return true;
  }

  void _drawSwipeAbleArc(Canvas canvas, Size size) {
    Path path = Path();

    path.moveTo(-2, size.height - archBottomOffset);
    path.cubicTo(
        -2,
        size.height - archBottomOffset,
        size.width / 2,
        size.height - arcHeight - archBottomOffset,
        size.width + 2,
        size.height - archBottomOffset);
    path.moveTo(size.width + 2, size.height - archBottomOffset);
    path.close();

    double left, right;
    if (showLeftAsFirstPage) {
      left = size.width / 2 - size.width / 2 * animation.value;
      right = size.width / 2;
      swipeArcPaint.color = Colors.green;
    } else {
      left = size.width / 2;
      right = size.width * animation.value;
      swipeArcPaint.color = Colors.deepPurple;
    }

    canvas.clipRect(Rect.fromLTRB(left, 0, right, size.height));

    canvas.drawPath(path, swipeArcPaint);
  }
}

class AmoebaBg extends CustomPainter {
  late Paint amoebaBgPaint;

  late final Animation<Offset> offsetAnimation;

  AmoebaBg(this.offsetAnimation) : super(repaint: offsetAnimation) {
    amoebaBgPaint = Paint();
    amoebaBgPaint.style = PaintingStyle.fill;
    amoebaBgPaint.strokeWidth = 4;
    amoebaBgPaint.color = Color.fromRGBO(255, 255, 255, .09);
    amoebaBgPaint.isAntiAlias = true;
    amoebaBgPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, 1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawTopAmoeba(canvas, size);
    canvas.translate(offsetAnimation.value.dx, offsetAnimation.value.dy);
    _drawLeftAmoeba(canvas, size);
    _drawRightAmoeba(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void _drawLeftAmoeba(Canvas canvas, Size size) {
    Path path = Path();
    path.moveTo(0, .1 * size.height);
    path.cubicTo(
      0,
      .1 * size.height,
      0.24 * size.width,
      .25 * size.height,
      0.28 * size.width,
      .26 * size.height,
    );
    path.cubicTo(
      0.28 * size.width,
      .26 * size.height,
      0.34 * size.width,
      .29 * size.height,
      0.30 * size.width,
      .33 * size.height,
    );
    path.cubicTo(
      0.31 * size.width,
      .32 * size.height,
      0.22 * size.width,
      .45 * size.height,
      0,
      .51 * size.height,
    );
    path.lineTo(0, .1 * size.height);

    canvas.drawPath(path, amoebaBgPaint);
  }

  void _drawRightAmoeba(Canvas canvas, Size size) {
    Path path = Path();
    path.moveTo(size.width * 1.4, 0);
    // path.quadraticBezierTo(
    //   size.width * .05,
    //   size.height * .40,
    //   size.width * 1.5,
    //   size.height * .33,
    // );

    path.cubicTo(size.width * 1.4, 0, size.width * .25, size.height * .30,
        size.width * .8, size.height * .33);

    path.cubicTo(size.width * .8, size.height * .33, size.width * 1.2,
        size.height * .35, size.width * 1.4, size.height * .5);

    path.lineTo(size.width, 0);

    canvas.drawPath(path, amoebaBgPaint);
  }

  void _drawTopAmoeba(Canvas canvas, Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.cubicTo(0, 0, (size.width * .85) * .5, size.height * .25,
        (size.width * .75), 0);
    path.lineTo(0, 0);

    canvas.drawPath(path, amoebaBgPaint);
  }
}

final double TAB_RIPPLE_RADIUS = 220;

class TabRippleEffect extends CustomPainter {
  final Animation<double> circleRadiusAnimation;
  final bool animateLeftSide;
  late Paint ripplePaint;

  TabRippleEffect(this.circleRadiusAnimation, this.animateLeftSide)
      : super(repaint: circleRadiusAnimation) {
    ripplePaint = Paint();
    ripplePaint.style = PaintingStyle.fill;
    ripplePaint.isAntiAlias = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Offset offset;
    if (this.animateLeftSide)
      offset = Offset(.25 * size.width, .05 * size.height);
    else
      offset = Offset(.75 * size.width, .05 * size.height);
    if (circleRadiusAnimation.value < TAB_RIPPLE_RADIUS-50)
      ripplePaint.color = Color.fromRGBO(
          0, 0, 0, .3 );
    else
      ripplePaint.color = Color.fromRGBO(0, 0, 0, 0);
    canvas.drawCircle(offset, circleRadiusAnimation.value, ripplePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
