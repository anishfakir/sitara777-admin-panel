import 'package:flutter/material.dart';

class TwilioConfig {
  // Twilio credentials - Use environment variables in production
  static const String accountSid = String.fromEnvironment('TWILIO_ACCOUNT_SID', defaultValue: 'demo');
  static const String authToken = String.fromEnvironment('TWILIO_AUTH_TOKEN', defaultValue: 'demo');
  static const String fromNumber = String.fromEnvironment('TWILIO_FROM_NUMBER', defaultValue: '+1234567890');

  // Demo mode settings - DISABLED for real-time OTP
  static const bool demoMode = false;
  static const String demoOtp = "123456";

  // API settings
  static const Duration timeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  // Message templates
  static const String otpMessageTemplate = "Your Sitara777 verification code is: {otp}. Valid for 10 minutes.";
  static const String resendMessageTemplate = "Your Sitara777 verification code is: {otp}. Valid for 10 minutes.";

  // Validation settings
  static const int otpLength = 6;
  static const int mobileLength = 10;
  static const String mobileRegex = r'^[6-9]\d{9}$';

  // Error messages
  static const String invalidMobileMessage = "Please enter a valid 10-digit mobile number";
  static const String invalidOtpMessage = "Please enter a valid 6-digit OTP";
  static const String networkErrorMessage = "Network error. Please check your internet connection.";
  static const String timeoutErrorMessage = "Request timeout. Please try again.";
  static const String maxRetriesMessage = "Maximum retry attempts reached. Please try again later.";

  // Success messages
  static const String otpSentMessage = "OTP sent successfully!";
  static const String otpVerifiedMessage = "OTP verified successfully!";
  static const String otpResentMessage = "OTP resent successfully!";

  // Demo messages
  static const String demoOtpSentMessage = "Demo OTP sent successfully! Use 123456 for verification.";
  static const String demoOtpResentMessage = "Demo OTP resent successfully! Use 123456 for verification.";
} 