# TaskFlow - Deployment Guide

Complete guide for building and deploying TaskFlow to Android and iOS devices.

## 📱 Android Deployment

### Prerequisites
- Flutter SDK installed and configured
- Android Studio with SDK tools
- JDK 11 or higher
- Physical device or emulator

### Debug Build (Testing)

#### Method 1: Via Android Studio
1. Open the project in Android Studio
2. Connect device or start emulator
3. Click **Run** button (▶️) or press `Shift + F10`
4. App installs automatically in debug mode

#### Method 2: Via Command Line
```bash
cd C:\Users\ASUS\AndroidStudioProjects\taskflow
flutter run
```

### Release Build (Production)

#### 1. Update Version
Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1  # 1.0.0 is version name, +1 is build number
```

#### 2. Configure App Icon & Name
**App Name**: Edit `android/app/src/main/AndroidManifest.xml`
```xml
<application
    android:label="TaskFlow"
    ...>
```

**App Icon**: Replace files in `android/app/src/main/res/mipmap-*/`
- Use [App Icon Generator](https://appicon.co/) for all sizes

#### 3. Create Keystore (First Time Only)

**Generate keystore**:
```bash
keytool -genkey -v -keystore C:\Users\ASUS\taskflow-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias taskflow
```

**Follow prompts**:
- Enter keystore password (remember this!)
- Enter key password (can be same as keystore)
- Fill in your information

#### 4. Configure Signing

Create `android/key.properties`:
```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=taskflow
storeFile=C:\\Users\\ASUS\\taskflow-keystore.jks
```

⚠️ **Important**: Add to `.gitignore`:
```
android/key.properties
*.jks
```

Edit `android/app/build.gradle`:
```gradle
// Add before android block
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    
    // Add signing config
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

#### 5. Build Release APK

```bash
flutter build apk --release
```

**Output location**:
```
build/app/outputs/flutter-apk/app-release.apk
```

**Size**: ~20-30 MB

#### 6. Build App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

**Output location**:
```
build/app/outputs/bundle/release/app-release.aab
```

### Install Release APK

**Via ADB**:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

**Via File Transfer**:
1. Copy APK to device
2. Open file manager
3. Tap APK file
4. Allow installation from unknown sources if prompted
5. Tap "Install"

### Split APK by Architecture (Smaller Size)

```bash
flutter build apk --split-per-abi
```

Generates separate APKs:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-x86_64-release.apk` (64-bit Intel)

Each ~10-15 MB

---

## 🍎 iOS Deployment

### Prerequisites
- macOS with Xcode 14+
- Apple Developer Account ($99/year for distribution)
- iPhone or iPad for testing
- CocoaPods installed

### Setup

#### 1. Install CocoaPods
```bash
sudo gem install cocoapods
```

#### 2. Install iOS Dependencies
```bash
cd ios
pod install
cd ..
```

#### 3. Open in Xcode
```bash
open ios/Runner.xcworkspace
```

#### 4. Configure Bundle ID
In Xcode:
1. Select **Runner** in left panel
2. Go to **General** tab
3. Change **Bundle Identifier**: `com.yourcompany.taskflow`

#### 5. Configure Team
1. Go to **Signing & Capabilities**
2. Select your **Team**
3. Enable **Automatically manage signing**

### Debug Build

#### Via Command Line
```bash
flutter run -d <device-id>
```

List devices:
```bash
flutter devices
```

#### Via Xcode
1. Select device from dropdown
2. Click **Run** button (▶️)

### Release Build

#### 1. Update Version
Edit `ios/Runner/Info.plist`:
```xml
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

#### 2. Build IPA
```bash
flutter build ipa --release
```

**Output location**:
```
build/ios/archive/Runner.xcarchive
```

#### 3. Archive in Xcode
1. Open `ios/Runner.xcworkspace`
2. Select **Any iOS Device** as target
3. Go to **Product → Archive**
4. Wait for archiving to complete
5. Click **Distribute App**
6. Follow wizard for App Store or Ad Hoc distribution

### TestFlight Distribution

1. Archive the app (steps above)
2. Select **App Store Connect**
3. Upload to TestFlight
4. Wait for processing (~15-30 min)
5. Add internal/external testers
6. Testers install via TestFlight app

---

## 🌐 Web Deployment

### Build Web Version

```bash
flutter build web --release
```

**Output location**:
```
build/web/
```

### Deploy to Firebase Hosting

#### 1. Install Firebase CLI
```bash
npm install -g firebase-tools
```

#### 2. Login
```bash
firebase login
```

#### 3. Initialize
```bash
firebase init hosting
```

Configuration:
- Public directory: `build/web`
- Single-page app: **Yes**
- Set up automatic builds: **No**

#### 4. Deploy
```bash
firebase deploy --only hosting
```

### Deploy to GitHub Pages

#### 1. Build with base href
```bash
flutter build web --release --base-href "/taskflow/"
```

#### 2. Push to gh-pages branch
```bash
git checkout -b gh-pages
cp -r build/web/* .
git add .
git commit -m "Deploy to GitHub Pages"
git push origin gh-pages
```

#### 3. Enable GitHub Pages
1. Go to repository **Settings**
2. Navigate to **Pages**
3. Select **gh-pages** branch
4. Save

Access at: `https://yourusername.github.io/taskflow/`

---

## 📦 Distribution Options

### Android

| Method | Use Case | Size | Requirements |
|--------|----------|------|--------------|
| APK | Direct install, testing | 20-30 MB | None |
| Split APK | Smaller per-device size | 10-15 MB | Know target architecture |
| App Bundle | Google Play Store | N/A | Play Store account |

### iOS

| Method | Use Case | Requirements |
|--------|----------|--------------|
| Debug | Development testing | Xcode + Device |
| Ad Hoc | Beta testing (100 devices) | Apple Developer Account |
| TestFlight | Public beta | Apple Developer Account |
| App Store | Public release | Apple Developer Account + Review |

---

## 🔐 Security Considerations

### Before Release

1. **Remove Debug Code**
   - Remove `print()` statements
   - Disable debug banners
   - Remove test accounts (or use secure credentials)

2. **Secure Database**
   - Currently passwords are plain text
   - Consider adding encryption for production
   - Use secure authentication (OAuth, JWT)

3. **API Keys**
   - If using external APIs, store keys securely
   - Use environment variables
   - Never commit keys to version control

4. **Obfuscate Code**
   ```bash
   flutter build apk --obfuscate --split-debug-info=build/debug-info
   ```

---

## 📊 Build Optimization

### Reduce App Size

1. **Use Split APKs**
   ```bash
   flutter build apk --split-per-abi
   ```

2. **Remove Unused Resources**
   Enable in `android/app/build.gradle`:
   ```gradle
   buildTypes {
       release {
           shrinkResources true
           minifyEnabled true
       }
   }
   ```

3. **Compress Images**
   - Use WebP format
   - Optimize PNG/JPEG files
   - Use appropriate resolutions

### Performance

1. **Profile Performance**
   ```bash
   flutter run --profile
   ```

2. **Analyze Bundle**
   ```bash
   flutter build apk --analyze-size
   ```

---

## 🧪 Pre-Release Checklist

- [ ] Test on multiple devices/OS versions
- [ ] Test all user flows (login, task creation, updates)
- [ ] Verify database operations
- [ ] Test offline scenarios
- [ ] Check landscape orientation
- [ ] Verify all permissions
- [ ] Test with low storage/memory
- [ ] Review app icon and splash screen
- [ ] Update version number
- [ ] Generate signed build
- [ ] Test release build on device
- [ ] Review app store listing

---

## 📱 Publishing to Stores

### Google Play Store

1. **Create Account**: [Google Play Console](https://play.google.com/console)
2. **Create App**: New app → Fill details
3. **Upload App Bundle**: Release → Production → Create release
4. **Fill Store Listing**:
   - App name: TaskFlow
   - Description: Team task management application
   - Screenshots: Take from different screens
   - Category: Productivity
5. **Content Rating**: Complete questionnaire
6. **Review and Publish**: Submit for review (24-48 hours)

### Apple App Store

1. **Create Account**: [App Store Connect](https://appstoreconnect.apple.com)
2. **Create App**: My Apps → + → New App
3. **Upload Build**: Via Xcode or Application Loader
4. **Fill Metadata**:
   - Name: TaskFlow
   - Subtitle: Team Task Management
   - Description: Full description
   - Keywords: task, management, team, productivity
   - Screenshots: Required for all device sizes
5. **Submit for Review**: Typically 1-3 days

---

## 🔄 Update Process

### Version Numbering
- **Major.Minor.Patch+Build**
- Example: `1.2.3+10`
  - `1` = Major version (breaking changes)
  - `2` = Minor version (new features)
  - `3` = Patch version (bug fixes)
  - `10` = Build number (auto-incremented)

### Publishing Update

1. Update `pubspec.yaml` version
2. Build new release
3. Upload to store
4. Update "What's New" section
5. Submit for review

### Force Update Strategy
- Check version on app start
- Compare with server version
- Show update dialog if outdated
- Redirect to store if critical update

---

## 📞 Support

For deployment issues:
- Check Flutter documentation: https://flutter.dev/docs/deployment
- Android Studio logs: View → Tool Windows → Logcat
- Xcode logs: View → Navigators → Reports

---

**Good luck with your deployment!** 🚀

