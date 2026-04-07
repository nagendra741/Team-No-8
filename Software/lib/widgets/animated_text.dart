import 'package:flutter/material.dart';

class AnimatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final Duration delay;
  final AnimationType animationType;

  const AnimatedText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 2000),
    this.delay = Duration.zero,
    this.animationType = AnimationType.typewriter,
  });

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

enum AnimationType {
  typewriter,
  fadeIn,
  slideUp,
  scale,
  shimmer,
}

class _AnimatedTextState extends State<AnimatedText>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _shimmerController;
  late Animation<int> _characterCount;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _characterCount = StepTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
        if (widget.animationType == AnimationType.shimmer) {
          _shimmerController.repeat();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.animationType) {
      case AnimationType.typewriter:
        return _buildTypewriterAnimation();
      case AnimationType.fadeIn:
        return _buildFadeInAnimation();
      case AnimationType.slideUp:
        return _buildSlideUpAnimation();
      case AnimationType.scale:
        return _buildScaleAnimation();
      case AnimationType.shimmer:
        return _buildShimmerAnimation();
    }
  }

  Widget _buildTypewriterAnimation() {
    return AnimatedBuilder(
      animation: _characterCount,
      builder: (context, child) {
        String animatedText = widget.text.substring(0, _characterCount.value);
        return Text(
          animatedText + (_characterCount.value < widget.text.length ? '|' : ''),
          style: widget.style,
        );
      },
    );
  }

  Widget _buildFadeInAnimation() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Text(
            widget.text,
            style: widget.style,
          ),
        );
      },
    );
  }

  Widget _buildSlideUpAnimation() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              widget.text,
              style: widget.style,
            ),
          ),
        );
      },
    );
  }

  Widget _buildScaleAnimation() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Text(
            widget.text,
            style: widget.style,
          ),
        );
      },
    );
  }

  Widget _buildShimmerAnimation() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Colors.transparent,
                Colors.white,
                Colors.transparent,
              ],
              stops: [
                (_shimmerAnimation.value - 1).clamp(0.0, 1.0),
                _shimmerAnimation.value.clamp(0.0, 1.0),
                (_shimmerAnimation.value + 1).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: widget.style?.copyWith(
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}