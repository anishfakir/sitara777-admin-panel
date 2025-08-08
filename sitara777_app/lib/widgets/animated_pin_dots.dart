import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedPinDots extends StatefulWidget {
  final int pinLength;
  final int enteredLength;
  final bool hasError;

  const AnimatedPinDots({
    super.key,
    required this.pinLength,
    required this.enteredLength,
    this.hasError = false,
  });

  @override
  State<AnimatedPinDots> createState() => _AnimatedPinDotsState();
}

class _AnimatedPinDotsState extends State<AnimatedPinDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.pinLength,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void didUpdateWidget(AnimatedPinDots oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.enteredLength != widget.enteredLength) {
      _updateAnimations();
    }
    
    if (oldWidget.hasError != widget.hasError && widget.hasError) {
      _showErrorAnimation();
    }
  }

  void _updateAnimations() {
    for (int i = 0; i < widget.pinLength; i++) {
      if (i < widget.enteredLength) {
        _controllers[i].forward();
      } else {
        _controllers[i].reverse();
      }
    }
  }

  void _showErrorAnimation() {
    for (int i = 0; i < widget.pinLength; i++) {
      _controllers[i].forward().then((_) {
        _controllers[i].reverse();
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.pinLength,
        (index) => _buildDot(index),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _animations[index],
      builder: (context, child) {
        final isFilled = index < widget.enteredLength;
        final scale = _animations[index].value;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.hasError
                  ? Colors.red
                  : isFilled
                      ? Colors.red
                      : Colors.grey[600],
              border: Border.all(
                color: widget.hasError
                    ? Colors.red
                    : isFilled
                        ? Colors.red
                        : Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: isFilled
                ? Transform.scale(
                    scale: scale,
                    child: const Icon(
                      Icons.circle,
                      size: 12,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}

class AnimatedPinInput extends StatefulWidget {
  final int pinLength;
  final Function(String) onPinChanged;
  final Function(String) onPinCompleted;
  final bool hasError;

  const AnimatedPinInput({
    super.key,
    required this.pinLength,
    required this.onPinChanged,
    required this.onPinCompleted,
    this.hasError = false,
  });

  @override
  State<AnimatedPinInput> createState() => _AnimatedPinInputState();
}

class _AnimatedPinInputState extends State<AnimatedPinInput> {
  String _pin = '';

  void _onNumberPressed(String number) {
    if (_pin.length < widget.pinLength) {
      setState(() {
        _pin += number;
      });
      
      widget.onPinChanged(_pin);
      
      if (_pin.length == widget.pinLength) {
        widget.onPinCompleted(_pin);
      }
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
      widget.onPinChanged(_pin);
    }
  }

  void _clearPin() {
    setState(() {
      _pin = '';
    });
    widget.onPinChanged(_pin);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedPinDots(
          pinLength: widget.pinLength,
          enteredLength: _pin.length,
          hasError: widget.hasError,
        ),
        const SizedBox(height: 32),
        _buildKeypad(),
      ],
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        for (int i = 0; i < 3; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int j = 1; j <= 3; j++)
                _buildKeypadButton((i * 3 + j).toString()),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80, height: 80),
            _buildKeypadButton('0'),
            _buildKeypadButton('delete', isDelete: true),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadButton(String value, {bool isDelete = false}) {
    return GestureDetector(
      onTap: () {
        if (isDelete) {
          _onDeletePressed();
        } else {
          _onNumberPressed(value);
        }
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Center(
          child: isDelete
              ? const Icon(
                  Icons.backspace,
                  color: Colors.white,
                  size: 24,
                )
              : Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
} 