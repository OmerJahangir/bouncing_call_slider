import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BouncingCallSlider extends StatefulWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  /// Customizable labels
  final String acceptText;
  final String declineText;

  /// Style options
  final TextStyle? textStyle;

  final Color acceptTextColor;
  final Color declineTextColor;
  final Color iconColorAccept;
  final Color iconColorDecline;
  final Color callBtnBackgroundColor;

 /// Icons can be replaced with custom widgets
  final Widget? acceptIcon;
  final Widget? declineIcon;
 
  /// Dimensions
  final double height;
  final double width;
  final double iconSize;
  final double buttonSize;

  const BouncingCallSlider({
    super.key,
    required this.onAccept,
    required this.onDecline,
    this.acceptText = 'Swipe up to answer',
    this.declineText = 'Swipe down to decline',
    this.textStyle,
    this.acceptTextColor = Colors.grey,
    this.declineTextColor = Colors.grey,
    this.iconColorAccept = Colors.green,
    this.iconColorDecline = Colors.red,
    this.callBtnBackgroundColor = Colors.white,
    this.acceptIcon,
    this.declineIcon,
    this.height = 200,
    this.width = 70,
    this.iconSize = 35,
    this.buttonSize = 70,
  });

  @override
  State<BouncingCallSlider> createState() => _BouncingCallSliderState();
}

class _BouncingCallSliderState extends State<BouncingCallSlider>
    with TickerProviderStateMixin {
  double _dragPosition = 0.0;
  /// final double _dragThreshold = 80.0; /// Min distance required to trigger action
  bool _hapticTriggered = false;
  bool _hasTriggeredAtTop = false;

  /// Controllers and animations for reset, bounce, shake, and rotate
  late AnimationController _resetController;
  late Animation<double> _resetAnimation;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  bool isDragging = false;

  @override
  void initState() {
    super.initState();

    /// Animation to return button to center after drag
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    /// Bounce effect for idle call button
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    /// Rotation animation triggered during bounce
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    /// Create bounce animation using easing curves
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -20,
          end: 10,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 10,
          end: -20,
        ).chain(CurveTween(curve: Curves.easeOutExpo)),
        weight: 90,
      ),
    ]).animate(_bounceController);

    /// Trigger haptics and rotation when bounce reaches the top
    _bounceAnimation.addListener(() {
      final value = _bounceAnimation.value;
      if (!isDragging && value <= -19.5 && !_hasTriggeredAtTop) {
        _hasTriggeredAtTop = true;
        _rotationController.forward(from: 0.0);
        HapticFeedback.mediumImpact();
      }
      if (value > -19.5 && _hasTriggeredAtTop) {
        _hasTriggeredAtTop = false;
      }
    });

    /// Small shake (jitter) animation when bouncing
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.50), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.50, end: 0.50), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.50, end: -0.30), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.30, end: 0.30), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.30, end: 0.0), weight: 1),
    ]).animate(_rotationController);
  }

  @override
  void dispose() {
    _resetController.dispose();
    _bounceController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  /// When drag ends, check if it passes the threshold to trigger action
  void _handleDragEnd(DragEndDetails details) {
    final double acceptDragLimit = widget.height * 0.8;
    final double declineDragLimit = widget.height * 0.4;

    if (_dragPosition <= -acceptDragLimit + 1) {
      widget.onAccept();
    } else if (_dragPosition >= declineDragLimit - 1) {
      widget.onDecline();
    }
    _animateReset();
  }

  /// Animate drag reset to original position
  void _animateReset() {
    _resetAnimation = Tween<double>(
      begin: _dragPosition,
      end: 0.0,
    ).animate(_resetController)..addListener(() {
      setState(() {
        _dragPosition = _resetAnimation.value;
      });
    });
    _resetController.forward(from: 0.0);
    _hapticTriggered = false;
  }

  @override
  Widget build(BuildContext context) {
    final bool isAccepting = _dragPosition < 0;
    final bool isDeclining = _dragPosition > 0;
    isDragging = _dragPosition != 0;

    final double acceptDragLimit = widget.height * 0.8;
    final double declineDragLimit = widget.height * 0.4;

    /// Used to interpolate color blending based on drag direction and distance
    final double dragRatio =
        _dragPosition < 0
            ? (_dragPosition / acceptDragLimit).clamp(-1.0, 0.0)
            : (_dragPosition / declineDragLimit).clamp(0.0, 1.0);

    /// Background color changes with drag toward green or red
    final Color dynamicBtnColor =
        dragRatio < 0
            ? Color.lerp(
              widget.callBtnBackgroundColor,
              Colors.green,
              -dragRatio,
            )!
            : dragRatio > 0
            ? Color.lerp(widget.callBtnBackgroundColor, Colors.red, dragRatio)!
            : widget.callBtnBackgroundColor;

    /// Icon color is white when dragging, otherwise it's themed
    final Color dynamicIconColor =
        (isAccepting || isDeclining)
            ? Colors.white
            : isAccepting
            ? widget.iconColorAccept
            : isDeclining
            ? widget.iconColorDecline
            : widget.iconColorAccept;

    /// Default fallback icons
    final Widget defaultAcceptIcon = Icon(
      Icons.call,
      color: dynamicIconColor,
      size: widget.iconSize,
    );
    final Widget defaultDeclineIcon = Icon(
      Icons.call_end,
      color: dynamicIconColor,
      size: widget.iconSize,
    );

    /// Pick icon based on drag direction
    final Widget iconWidget =
        isAccepting
            ? (widget.acceptIcon ?? defaultAcceptIcon)
            : isDeclining
            ? (widget.declineIcon ?? defaultDeclineIcon)
            : defaultAcceptIcon;

    /// Trigger haptic once per drag beyond threshold
    if (!_hapticTriggered &&
        (_dragPosition < -acceptDragLimit * 0.8 - 5 ||
            _dragPosition > declineDragLimit * 0.4 + 5)) {
      HapticFeedback.mediumImpact();
      _hapticTriggered = true;
    }

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          _dragPosition += details.delta.dy;
          _dragPosition =
              _dragPosition < 0
                  ? _dragPosition.clamp(-acceptDragLimit, 0)
                  : _dragPosition.clamp(0, declineDragLimit);
        });
      },
      onVerticalDragEnd: _handleDragEnd,
      child: SizedBox(
        height: widget.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ///-------------------------------------------------------------------------
            ///----------------------------- ANSWER TEXT -------------------------------
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                final double totalOffset =
                    isDragging ? _dragPosition : _bounceAnimation.value;

                return Transform.translate(
                  offset: Offset(0, totalOffset),
                  child: Column(
                    children: [
                      /// Accept label fades with drag amount
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 50),
                        opacity: (1.0 -
                                (_dragPosition.abs() /
                                    (_dragPosition < 0
                                        ? acceptDragLimit
                                        : declineDragLimit)))
                            .clamp(0.0, 1.0),
                        child: Text(
                          widget.acceptText,
                          style:
                              widget.textStyle ??
                              TextStyle(
                                color: widget.acceptTextColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      ///-------------------------------------------------------------------------
                      ///----------------------------- CALL BUTTON -------------------------------

                      /// Call button with bounce, shake, and rotation
                      Container(
                        height: widget.buttonSize,
                        width: widget.buttonSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: dynamicBtnColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 5,
                              spreadRadius: 0.1,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: AnimatedBuilder(
                          animation: Listenable.merge([_rotationAnimation]),
                          builder: (context, child) {
                            return Transform.rotate(
                              angle:
                                  isDragging ? 0.0 : _rotationAnimation.value,
                              child: child,
                            );
                          },
                          child: iconWidget,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            ///--------------------------------------------------------------------------
            ///----------------------------- DECLINE TEXT -------------------------------

            /// Bottom: Decline label with fade out
            AnimatedOpacity(
              duration: const Duration(milliseconds: 50),
              opacity:
                  _dragPosition < 0
                      ? 0.0
                      : (1.0 - (_dragPosition / (declineDragLimit * 0.6)))
                          .clamp(0.0, 1.0),

              child: Text(
                widget.declineText,
                style:
                    widget.textStyle ??
                    TextStyle(
                      color: widget.declineTextColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
