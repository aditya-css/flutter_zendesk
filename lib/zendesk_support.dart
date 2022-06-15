import 'dart:async';

import 'package:flutter/services.dart';

class ZendeskSupport {
  static const MethodChannel _channel = MethodChannel('zendesk_support');
  static const _initialize = "initialize";
  static const _setVisitorInfo = "setVisitorInfo";
  static const _startChat = "startChat";

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> initialize({
    required String zendeskUrl,
    required String appId,
    required String oauthClientId,
    required String chatAccountKey,
  }) async {
    await _channel.invokeMethod<void>(_initialize, {
      "zendeskUrl": zendeskUrl,
      "appId": appId,
      "oauthClientId": oauthClientId,
      "chatAccountKey": chatAccountKey,
    });
  }

  static Future<void> setVisitorInfo({
    String? name,
    String? email,
    String? phoneNumber,
  }) async {
    await _channel.invokeMethod<void>(_setVisitorInfo, {
      "name": name,
      "email": email,
      "phoneNumber": phoneNumber,
    });
  }

  static Future<void> startChat() async => await _channel.invokeMethod<void>(_startChat);
}
