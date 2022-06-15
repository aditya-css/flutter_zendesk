import 'package:flutter/material.dart';
import 'package:zendesk_support/zendesk_support.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    await ZendeskSupport.initialize(
      zendeskUrl: "https://saprevab.zendesk.com",
      appId: "36eff5fcb504ba97660790ab23faab02df0b38fb4f3c33c6",
      oauthClientId: "mobile_sdk_client_2cfa3325fc151b903227",
      chatAccountKey: "xKnn9tHZJhWta4pp3S8o3QxSTyijAPJz",
    );
    await ZendeskSupport.setVisitorInfo(
      name: "FlutterDemo",
      email: "flutterDemo@gmail.com",
      phoneNumber: "123456789",
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              try {
                await ZendeskSupport.startChat();
              } catch (e) {
                print("Error====${e.toString()}");
              }
            },
            child: const Text("Support"),
          ),
        ),
      ),
    );
  }
}
