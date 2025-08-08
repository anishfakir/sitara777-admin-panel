# Twilio OTP Integration Setup Guide

## Overview
This Flutter app now uses Twilio for SMS/OTP functionality instead of MSG91. The implementation includes demo mode for testing and production mode for real SMS.

## Setup Instructions

### 1. Get Twilio Credentials
1. Sign up for a Twilio account at [https://www.twilio.com](https://www.twilio.com)
2. Get your Account SID and Auth Token from the Twilio Console
3. Purchase a phone number for sending SMS

### 2. Configure Twilio Credentials
Update the credentials in `lib/config/twilio_config.dart`:

```dart
class TwilioConfig {
  // Replace these with your actual Twilio credentials
  static const String accountSid = "YOUR_TWILIO_ACCOUNT_SID";
  static const String authToken = "YOUR_TWILIO_AUTH_TOKEN";
  static const String fromNumber = "YOUR_TWILIO_PHONE_NUMBER";
  
  // Demo mode settings (set to false for production)
  static const bool demoMode = true;
  static const String demoOtp = "123456";
}
```

### 3. Enable Production Mode
To enable real SMS sending, change in `lib/config/twilio_config.dart`:
```dart
static const bool demoMode = false;
```

### 4. Test the Integration

#### Demo Mode Testing:
- Use any valid Indian mobile number (10 digits starting with 6-9)
- OTP will always be: `123456`
- No real SMS will be sent

#### Production Mode Testing:
- Use real mobile numbers
- Real SMS will be sent with actual OTP
- Verify the OTP received on the phone

## Features

### ✅ Implemented Features:
- **Mobile Number Validation**: Indian format (10 digits starting with 6-9)
- **OTP Generation**: Random 6-digit OTP
- **SMS Sending**: Via Twilio API
- **OTP Verification**: Secure verification process
- **Resend OTP**: With timer and rate limiting
- **Error Handling**: Comprehensive error messages
- **Demo Mode**: For testing without SMS costs
- **Production Mode**: Real SMS functionality

### 🔧 Configuration Options:
- **Timeout Settings**: Configurable API timeouts
- **Retry Logic**: Automatic retry on failures
- **Message Templates**: Customizable SMS messages
- **Validation Rules**: Configurable mobile/OTP validation

## API Endpoints Used

### Twilio SMS API:
- **URL**: `https://api.twilio.com/2010-04-01/Accounts/{AccountSid}/Messages.json`
- **Method**: POST
- **Authentication**: Basic Auth with Account SID and Auth Token
- **Parameters**:
  - `To`: Recipient phone number (+91XXXXXXXXXX)
  - `From`: Your Twilio phone number
  - `Body`: SMS message content

## Error Handling

### Common Errors:
1. **Invalid Mobile Number**: Must be 10 digits starting with 6-9
2. **Invalid OTP**: Must be exactly 6 digits
3. **Network Errors**: Connection issues
4. **Timeout Errors**: API response timeout
5. **Authentication Errors**: Invalid Twilio credentials

### Error Messages:
- All error messages are configurable in `TwilioConfig`
- User-friendly messages displayed to users
- Detailed logging for debugging

## Security Considerations

### ✅ Security Features:
- **OTP Expiration**: OTPs expire after verification
- **Rate Limiting**: Prevents spam OTP requests
- **Input Validation**: Strict mobile number and OTP validation
- **Secure Storage**: OTPs not stored permanently
- **HTTPS Only**: All API calls use HTTPS

### 🔒 Best Practices:
1. **Never expose credentials** in client-side code
2. **Use environment variables** for production
3. **Implement rate limiting** on your backend
4. **Log security events** for monitoring
5. **Regular credential rotation**

## Testing

### Demo Mode Testing:
```bash
# Install the app
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk

# Test scenarios:
1. Enter mobile: 9876543210
2. Send OTP → Should show success message
3. Enter OTP: 123456
4. Verify → Should login successfully
```

### Production Mode Testing:
```bash
# Change demo mode to false
# Update Twilio credentials
# Test with real mobile numbers
```

## Troubleshooting

### Common Issues:

1. **"Invalid Account SID"**
   - Check your Twilio Account SID
   - Ensure it's copied correctly

2. **"Authentication Failed"**
   - Verify your Auth Token
   - Check if credentials are correct

3. **"SMS Not Delivered"**
   - Verify your Twilio phone number
   - Check if the number is active
   - Ensure sufficient credits

4. **"Network Error"**
   - Check internet connection
   - Verify API endpoints
   - Check firewall settings

### Debug Mode:
Enable debug logging by adding:
```dart
print('Twilio API Response: $responseData');
```

## Cost Considerations

### Twilio Pricing:
- **SMS Cost**: ~$0.0075 per SMS (US numbers)
- **International**: Varies by country
- **Free Trial**: $15-20 credit for new accounts

### Optimization Tips:
1. **Use demo mode** for development
2. **Implement caching** for repeated OTPs
3. **Rate limiting** to prevent abuse
4. **Monitor usage** to control costs

## Migration from MSG91

### Changes Made:
1. **Service Replacement**: MSG91 → Twilio
2. **API Integration**: Updated HTTP calls
3. **Error Handling**: Enhanced error messages
4. **Configuration**: Centralized config management

### Benefits:
- **Better Documentation**: Twilio has excellent docs
- **Global Coverage**: Better international support
- **Reliability**: More stable API
- **Features**: Rich SMS features

## Support

For issues with:
- **Twilio API**: Contact Twilio Support
- **Flutter Integration**: Check this documentation
- **App Issues**: Review error logs

## Next Steps

1. **Test thoroughly** in demo mode
2. **Configure production** credentials
3. **Deploy to production** with real SMS
4. **Monitor usage** and costs
5. **Implement analytics** for OTP success rates 