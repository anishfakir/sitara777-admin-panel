import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/base_game_screen.dart';

class SingleDigitScreen extends StatelessWidget {
  const SingleDigitScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseGameScreen(
      gameName: 'Single Digit',
      contentBuilder: _buildGameContent,
    );
  }

  Widget _buildGameContent(BuildContext context, BaseGameScreenState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Game Rules
        _buildGameRules(),
        const SizedBox(height: 16),

        // Digit Input Section
        const Text(
          'Select Digit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _buildDigitInput(state),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDigitInput(BaseGameScreenState state) {
    return TextFormField(
      controller: state.digitController,
      focusNode: state.digitFocusNode,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(1),
      ],
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
      decoration: AppTheme.gameInputDecoration(
        hintText: 'Enter digit (0-9)',
      ).copyWith(
        hintStyle: const TextStyle(
          fontSize: 16,
          color: AppTheme.textTertiary,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a digit';
        }
        final digit = int.tryParse(value);
        if (digit == null || digit < 0 || digit > 9) {
          return 'Please enter a valid digit (0-9)';
        }
        return null;
      },
      onFieldSubmitted: (value) {
        // Move focus to points field
        state.pointFocusNode.requestFocus();
      },
    );
  }

  Widget _buildGameRules() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.inputBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Game Rules',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '• Select any single digit from 0 to 9\n'
            '• Minimum bet: ₹10\n'
            '• Maximum bet: ₹50,000\n'
            '• Winning ratio: 1:9.5\n'
            '• Results are declared every day',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
