# Database Reset Instructions

## Issue: Duplicate Column Error

If you see errors like:
```
duplicate column name: contact_number (code 1 SQLITE_ERROR)
```

This means the database schema is corrupted or in an inconsistent state.

## Quick Fix Options

### Option 1: Clear App Data (Recommended)
This will delete the database and start fresh:

**On Emulator:**
1. Go to: Settings → Apps → TaskFlow
2. Click: Storage → Clear Data
3. Restart the app with `flutter run`

**On Physical Device:**
1. Long press TaskFlow app icon
2. App Info → Storage → Clear Data
3. Restart the app

### Option 2: Uninstall and Reinstall
```powershell
# Uninstall from device
flutter clean
flutter run
```

The app will automatically uninstall the old version and install fresh.

### Option 3: Delete Database Programmatically
Add this code to main.dart temporarily:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // DELETE DATABASE (TEMPORARY FIX)
  await SQLiteDatabaseHelper.instance.deleteDatabase();
  print('✓ Database deleted - fresh start');
  
  // Rest of initialization...
}
```

Then after running once, remove the line.

### Option 4: Hot Restart
If the fix I applied works, just press:
```
R  (capital R in your flutter terminal)
```

## What I Fixed

I updated the database migration code to:
1. Skip adding columns that already exist
2. Handle duplicate column errors gracefully
3. Continue app startup even if migration has issues

## Test the Fix

Press `R` in your Flutter terminal to hot restart with the new code.

The error should be caught and the app should continue to load.

## If Error Persists

Clear app data using Option 1 or 2 above, then run:
```powershell
flutter run
```

The app will create a fresh database with the correct schema.

