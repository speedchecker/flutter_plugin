package com.speedchecker.speed_checker_plugin;


import android.app.Activity;
import android.content.Context;
import androidx.annotation.NonNull;

import com.speedchecker.android.sdk.Public.SpeedTestListener;
import com.speedchecker.android.sdk.Public.SpeedTestResult;
import com.speedchecker.android.sdk.SpeedcheckerSDK;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;

/** SpeedCheckerPlugin */
public class SpeedCheckerPlugin implements FlutterPlugin, ActivityAware {

  private static final String EVENT_CHANNEL = "speedChecker_eventChannel";
  private EventChannel.EventSink eventSink;
  private final Map<String, Object> map = new HashMap<>();
  private Context context;
  private Activity activity;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    EventChannel eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), EVENT_CHANNEL);
    eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
      @Override
      public void onListen(Object arguments, EventChannel.EventSink events) {
        eventSink = events;
        SpeedcheckerSDK.SpeedTest.setOnSpeedTestListener(new SpeedTestListener() {
          @Override
          public void onTestStarted() {
            map.put("status", "Speed test started");
            map.put("server", "");
            map.put("ping", 0);
            map.put("downloadSpeed", 0);
            map.put("percent", 0);
            map.put("currentSpeed", 0);
            map.put("uploadSpeed", 0);
            map.put("connectionType", "");
            eventSink.success(map);
          }

          @Override
          public void onFetchServerFailed() {

          }

          @Override
          public void onFindingBestServerStarted() {

          }

          @Override
          public void onTestFinished(SpeedTestResult speedTestResult) {
            map.put("status", "Speed test finished");
            map.put("server", speedTestResult.getServer().Domain);
            map.put("ping", speedTestResult.getPing());
            map.put("downloadSpeed", speedTestResult.getDownloadSpeed());
            map.put("uploadSpeed", speedTestResult.getUploadSpeed());
            map.put("connectionType", speedTestResult.getConnectionTypeHuman());
            eventSink.success(map);
          }

          @Override
          public void onPingStarted() {
            map.put("status", "Ping");
            eventSink.success(map);
          }

          @Override
          public void onPingFinished(int ping, int jitter) {
            map.put("ping", ping);
            eventSink.success(map);
          }

          @Override
          public void onDownloadTestStarted() {
            map.put("status", "Download");
            eventSink.success(map);
          }

          @Override
          public void onDownloadTestProgress(int percent, double speedMbs, double transferredMb) {
            map.put("percent", percent);
            map.put("currentSpeed", speedMbs);
            eventSink.success(map);
          }

          @Override
          public void onDownloadTestFinished(double speedMbs) {
            map.put("downloadSpeed", speedMbs);
          }

          @Override
          public void onUploadTestStarted() {
            map.put("status", "Upload");
            map.put("currentSpeed", 0);
            map.put("percent", 0);
            eventSink.success(map);
          }

          @Override
          public void onUploadTestProgress(int percent, double speedMbs, double transferredMb) {
            map.put("percent", percent);
            map.put("currentSpeed", speedMbs);
            eventSink.success(map);
          }

          @Override
          public void onUploadTestFinished(double speedMbs) {
            map.put("uploadSpeed", speedMbs);

          }

          @Override
          public void onTestWarning(String warning) {
            map.put("warning", warning);
            eventSink.success(map);
          }

          @Override
          public void onTestFatalError(String error) {
            map.put("error", error);
            eventSink.success(map);
          }

          @Override
          public void onTestInterrupted(String s) {
            map.put("error", s);
            eventSink.success(map);
          }
        });
        SpeedcheckerSDK.SpeedTest.startTest(context);
      }

      @Override
      public void onCancel(Object arguments) {
        eventSink = null;
      }
    });
  }
  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
    context = activity.getApplicationContext();
    SpeedcheckerSDK.init(context);
    SpeedcheckerSDK.askPermissions(activity);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

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
