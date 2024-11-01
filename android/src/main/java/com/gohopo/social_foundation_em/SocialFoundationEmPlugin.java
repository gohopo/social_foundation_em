package com.gohopo.social_foundation_em;

import android.app.Activity;
import android.content.Context;
import androidx.annotation.NonNull;

import com.gohopo.social_foundation_em.push.PushManager;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class SocialFoundationEmPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  public static MethodChannel channel;
  public static Context context;
  public static Activity activity;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "social_foundation_em");
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
  }
  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("registerPush")) {
      PushManager.registerPush(activity);
    } else {
      result.notImplemented();
    }
  }
  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }
  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }
  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {

  }
  @Override
  public void onDetachedFromActivity() {

  }
}
