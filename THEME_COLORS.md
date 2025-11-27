# App Theme Colors 🎨

## Current Color Scheme

The app now uses a **Red, Green, Blue** color scheme that applies throughout the entire app automatically!

### Primary Colors:

**🔴 Red (Primary)**
- Color: `#E53935` (Vibrant Red)
- Used for:
  - App bars
  - Primary buttons
  - Live match indicators
  - Important actions
  - Tab indicators

**🟢 Green (Secondary)**
- Color: `#43A047` (Cricket Green)
- Used for:
  - Secondary buttons
  - Success messages
  - Positive indicators
  - Completed states

**🔵 Blue (Tertiary)**
- Color: `#1E88E5` (Sky Blue)
- Used for:
  - Links
  - Information
  - Alternative actions
  - Highlights

### How It Works:

All colors are defined in **one file**: `lib/theme/app_theme.dart`

When you change colors there, the entire app updates automatically because all screens use:
- `Theme.of(context).colorScheme.primary` (Red)
- `Theme.of(context).colorScheme.secondary` (Green)
- `Theme.of(context).colorScheme.tertiary` (Blue)

### To Change Colors:

1. Open `lib/theme/app_theme.dart`
2. Update the color values:
   ```dart
   primary: const Color(0xFFE53935), // Change this hex code
   secondary: const Color(0xFF43A047), // Change this hex code
   tertiary: const Color(0xFF1E88E5), // Change this hex code
   ```
3. Save the file
4. Hot reload the app
5. All screens update automatically! ✨

### Color Usage Examples:

**Red (Primary):**
- App bar backgrounds
- Live match badges
- Primary action buttons
- Selected tabs

**Green (Secondary):**
- Create buttons
- Success notifications
- Completed match indicators
- Positive feedback

**Blue (Tertiary):**
- Information text
- Links
- Alternative buttons
- Highlights

### Benefits:

✅ Change once, apply everywhere
✅ Consistent design across all screens
✅ Easy to maintain
✅ Professional look
✅ No need to edit individual pages

### Current Theme File Location:
`lib/theme/app_theme.dart`

Just edit that one file to change the entire app's color scheme!
