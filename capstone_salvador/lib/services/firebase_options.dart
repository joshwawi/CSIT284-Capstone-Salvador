import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseOptionsConfig {
  const FirebaseOptionsConfig._();

  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _senderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const _webAppId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
  static const _androidAppId = String.fromEnvironment(
    'FIREBASE_ANDROID_APP_ID',
  );
  static const _iosAppId = String.fromEnvironment('FIREBASE_IOS_APP_ID');
  static const _macosAppId = String.fromEnvironment('FIREBASE_MACOS_APP_ID');
  static const _authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');

  static FirebaseOptions? currentPlatformOptions() {
    final appId = switch (defaultTargetPlatform) {
      TargetPlatform.android => _androidAppId,
      TargetPlatform.iOS => _iosAppId,
      TargetPlatform.macOS => _macosAppId,
      _ => null,
    };

    final isWeb = kIsWeb;
    final selectedAppId = isWeb ? _webAppId : appId;
    if (_apiKey.isEmpty ||
        _projectId.isEmpty ||
        _senderId.isEmpty ||
        selectedAppId == null ||
        selectedAppId.isEmpty ||
        (isWeb && _authDomain.isEmpty)) {
      return null;
    }

    return FirebaseOptions(
      apiKey: _apiKey,
      appId: selectedAppId,
      messagingSenderId: _senderId,
      projectId: _projectId,
      authDomain: isWeb ? _authDomain : null,
    );
  }
}
