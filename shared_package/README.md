# Dance Shared Package

This package contains shared code for Dance in SF applications, including authentication, logging, storage, and deep linking functionality.

## Features

- **Authentication**: Complete auth service with email/password, Google, Apple, and phone OTP
- **Logging**: Navigation and user activity logging with database sync
- **Storage**: Shared preferences and app storage utilities
- **Deep Linking**: Universal link handling for both mobile and web
- **Supabase Config**: Centralized database configuration

## Usage

### 1. Add to your app's pubspec.yaml

```yaml
dependencies:
  dance_shared:
    path: ../shared_package  # Adjust path as needed
```

### 2. Initialize in your main.dart

```dart
import 'package:dance_shared/dance_shared.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  // Initialize app storage
  await AppStorage.init();
  
  runApp(const MyApp());
}
```

### 3. Use authentication

```dart
import 'package:dance_shared/dance_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    if (authState.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (authState.user != null) {
      return HomeScreen();
    } else {
      return LoginScreen();
    }
  }
}
```

### 4. Use logging

```dart
import 'package:dance_shared/dance_shared.dart';

// Log navigation events
await LogController.logNavigation('User visited home screen');

// Handle sign-in callback
await LogController.signedInCallback();
```

### 5. Use deep linking

```dart
import 'package:dance_shared/dance_shared.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeUniLinks();
  }

  Future<void> _initializeUniLinks() async {
    await UniLinksHandler.initialize(
      onLinkReceived: (String link, bool initial) {
        final cleanPath = UniLinksHandler.parseLink(link);
        if (cleanPath != null) {
          // Handle the link with your router
          context.go(cleanPath);
        }
      },
    );
  }

  @override
  void dispose() {
    UniLinksHandler.dispose();
    super.dispose();
  }
}
```

## Structure

```
shared_package/
├── lib/
│   ├── auth/
│   │   └── auth_service.dart      # Authentication service
│   ├── config/
│   │   └── supabase_config.dart   # Supabase configuration
│   ├── utils/
│   │   ├── app_storage.dart       # Shared preferences
│   │   ├── log_controller.dart    # Logging service
│   │   └── uni_links.dart         # Deep linking
│   └── dance_shared.dart          # Main library exports
└── pubspec.yaml
```

## Migration from existing app

To migrate your existing app to use this shared package:

1. Remove the duplicate files from your app
2. Update imports to use `package:dance_shared/dance_shared.dart`
3. Update your main.dart to use `SupabaseConfig.initialize()` instead of direct Supabase initialization
4. Test all functionality to ensure it works correctly

## Benefits

- **Code Reuse**: Share authentication, logging, and storage between apps
- **Consistency**: Same auth flow and data handling across apps
- **Maintenance**: Update shared code in one place
- **Scalability**: Easy to add new shared functionality 