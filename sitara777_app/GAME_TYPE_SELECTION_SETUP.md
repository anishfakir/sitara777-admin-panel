# GameTypeSelectionScreen Setup Guide

## Overview
A clean, responsive Flutter screen that displays game types in a 3x3 grid layout with circular buttons.

## File Location
`lib/screens/game_type_selection_screen.dart`

## Features
- ✅ Pure white background (#FFFFFF)
- ✅ Black AppBar with dynamic title
- ✅ White back button
- ✅ 3x3 grid layout of circular buttons
- ✅ Icons from your GameIcon assets folder
- ✅ Black border with subtle shadow on buttons
- ✅ Bold, readable text labels
- ✅ OnTap navigation handling
- ✅ Error handling for missing images
- ✅ Responsive design

## Game Types Included
1. Single Digit
2. Jodi Digit
3. Single Panna
4. Double Panna
5. Triple Panna
6. Half Sangam
7. Full Sangam

## Usage

### Basic Navigation
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => GameTypeSelectionScreen(
      appBarTitle: "MADHUR MORNING",
    ),
  ),
);
```

### Different Market Examples
```dart
// For different markets/times
GameTypeSelectionScreen(appBarTitle: "MADHUR DAY")
GameTypeSelectionScreen(appBarTitle: "KALYAN NIGHT")
GameTypeSelectionScreen(appBarTitle: "MILAN DAY")
```

## Integration with Existing Screens

### From GameMarketScreen
Replace the existing game type navigation with:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => GameTypeSelectionScreen(
      appBarTitle: widget.market?.name ?? 'Market',
    ),
  ),
);
```

### From Market Selection
```dart
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GameTypeSelectionScreen(
        appBarTitle: marketName,
      ),
    ),
  );
}
```

## Customization Options

### Navigation Implementation
Currently shows "Coming Soon" messages. To implement actual navigation:

1. Uncomment the navigation lines in `_navigateToGameScreen()`
2. Import your actual game screens
3. Replace the commented Navigator.push calls

Example:
```dart
case 'Single Digit':
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SingleDigitScreen(
        marketName: appBarTitle,
      ),
    ),
  );
  break;
```

### Icon Customization
The screen uses icons from `assets/GameIcon/` folder:
- `single-digits.png`
- `jodi.png`
- `single-pana.png`
- `double-pana.png`
- `triple-pana.png`
- `half-sangam-a.png`
- `full-sangam.png`

If an icon fails to load, it shows a fallback casino icon.

## Technical Details
- Uses `GridView.builder` for better performance
- Responsive design with `childAspectRatio: 0.85`
- Safe area implementation for different screen sizes
- Error handling for missing assets
- Clean, maintainable code structure

## Assets Required
Make sure these images exist in your `assets/GameIcon/` folder:
- single-digits.png
- jodi.png
- single-pana.png
- double-pana.png
- triple-pana.png
- half-sangam-a.png
- full-sangam.png

## Next Steps
1. Test the screen with your existing navigation
2. Implement actual game screen navigation
3. Customize colors/styling if needed
4. Add any additional game types as required
