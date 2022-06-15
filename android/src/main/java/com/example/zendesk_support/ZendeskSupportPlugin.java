package com.example.zendesk_support;

import android.content.Context;

import androidx.annotation.NonNull;

import java.util.List;

import android.app.Activity;
import android.util.Log;

import com.zendesk.logger.Logger;

import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import zendesk.answerbot.AnswerBot;
import zendesk.answerbot.AnswerBotEngine;
import zendesk.chat.Chat;
import zendesk.chat.ChatConfiguration;
import zendesk.chat.ChatEngine;
import zendesk.chat.ChatProvidersConfiguration;
import zendesk.chat.VisitorInfo;
import zendesk.configurations.Configuration;
import zendesk.core.AnonymousIdentity;
import zendesk.core.Identity;
import zendesk.core.Zendesk;
import zendesk.messaging.Engine;
import zendesk.messaging.MessagingActivity;
import zendesk.support.Guide;
import zendesk.support.Support;
import zendesk.support.SupportEngine;

/**
 * ZendeskSupportPlugin
 */
public class ZendeskSupportPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private Context context;
    private Activity activity;


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "zendesk_support");
        channel.setMethodCallHandler(this);
        this.context = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            case "initialize":
                initialize(call);
                result.success(true);
                break;
            case "setVisitorInfo":
                setVisitorInfo(call);
                result.success(true);
                break;
            case "startChat":
                startChat();
                result.success(true);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    public void initialize(@NonNull MethodCall call) {
        Logger.setLoggable(true);
        final String zendeskUrl = call.argument("zendeskUrl");
        final String appId = call.argument("appId");
        final String oauthClientId = call.argument("oauthClientId");
        final String chatAccountKey = call.argument("chatAccountKey");
        Zendesk.INSTANCE.init(activity, zendeskUrl, appId, oauthClientId);
        Support.INSTANCE.init(Zendesk.INSTANCE);
        AnswerBot.INSTANCE.init(Zendesk.INSTANCE, Guide.INSTANCE);
        Chat.INSTANCE.init(activity, chatAccountKey);
    }

    public void setVisitorInfo(@NonNull MethodCall call) {
        Logger.setLoggable(true);
        final String name = call.argument("name");
        final String email = call.argument("email");
        final String phoneNumber = call.argument("phoneNumber");
        Identity identity = new AnonymousIdentity.Builder()
                .withNameIdentifier(name)
                .withEmailIdentifier(email).build();
        Zendesk.INSTANCE.setIdentity(identity);
        VisitorInfo visitorInfo = VisitorInfo.builder()
                .withName(name)
                .withEmail(email)
                .withPhoneNumber(phoneNumber)
                .build();


        ChatProvidersConfiguration chatProvidersConfiguration = ChatProvidersConfiguration.builder()
                .withVisitorInfo(visitorInfo)
                .build();

        Chat.INSTANCE.setChatProvidersConfiguration(chatProvidersConfiguration);
    }

    public void startChat() {
        Logger.setLoggable(true);
        Engine answerBotEngine = AnswerBotEngine.engine();
        Engine supportEngine = SupportEngine.engine();
        Engine chatEngine = ChatEngine.engine();
        ChatConfiguration chatConfiguration = ChatConfiguration.builder().withAgentAvailabilityEnabled(false).build();
        MessagingActivity.builder()
                .withEngines(answerBotEngine, supportEngine, chatEngine)
                .show(activity, chatConfiguration);
    }


    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        activity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
        activity = null;
    }
}
