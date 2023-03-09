package com.speedchecker.speed_checker_plugin;


import android.content.Context;
import android.os.Build;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;

import com.speedchecker.android.sdk.Public.Server;
import com.speedchecker.android.sdk.Public.SpeedTestListener;
import com.speedchecker.android.sdk.Public.SpeedTestResult;
import com.speedchecker.android.sdk.SpeedcheckerSDK;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * SpeedCheckerPlugin
 */
public class SpeedCheckerPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {

	private static final String EVENT_CHANNEL = "speedChecker_eventChannel";
	private EventChannel.EventSink eventSink;
	private final Map<String, Object> map = new HashMap<>();
	private Context context;
	private String domain = "";
	private String ip = "";

	@Override
	public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
		EventChannel eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), EVENT_CHANNEL);
		context = flutterPluginBinding.getApplicationContext();
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
						map.put("jitter", 0);
						map.put("downloadSpeed", 0);
						map.put("percent", 0);
						map.put("currentSpeed", 0);
						map.put("uploadSpeed", 0);
						map.put("connectionType", "");
						map.put("serverInfo", "");
						map.put("locationLatitude", 0F);
						map.put("locationLongitude", 0F);
						map.put("locationAccuracy", 0F);
						map.put("deviceInfo", "");
						map.put("cityName", "");
						map.put("downloadTransferredMb", 0.0);
						map.put("uploadTransferredMb", 0.0);
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
						map.put("jitter", speedTestResult.getJitter());
						map.put("downloadSpeed", speedTestResult.getDownloadSpeed());
						map.put("uploadSpeed", speedTestResult.getUploadSpeed());
						map.put("connectionType", speedTestResult.getConnectionTypeHuman());
						map.put("serverInfo", speedTestResult.getServerInfo());
						map.put("locationLatitude", speedTestResult.getLocationLatitude());
						map.put("locationLongitude", speedTestResult.getLocationLongitude());
						map.put("locationAccuracy", speedTestResult.getLocationAccuracy());
						map.put("deviceInfo", speedTestResult.getDeviceInfo());
						map.put("cityName", speedTestResult.getCityName());
						map.put("downloadTransferredMb", speedTestResult.getDownloadTransferredMb());
						map.put("uploadTransferredMb", speedTestResult.getUploadTransferredMb());
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
						map.put("jitter", jitter);
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
						map.put("downloadTransferredMb", transferredMb);
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
						map.put("uploadTransferredMb", transferredMb);
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
				checkPermission(context);
			}

			@Override
			public void onCancel(Object arguments) {
				eventSink = null;
			}
		});
	}

	private void checkPermission(Context context) {
		if (context != null) {
			if (Build.VERSION.SDK_INT >= 30) {
				if (ActivityCompat.checkSelfPermission(context, "android.permission.ACCESS_COARSE_LOCATION") != 0 || ActivityCompat.checkSelfPermission(context, "android.permission.ACCESS_FINE_LOCATION") != 0) {
					Toast.makeText(context, "Please grant location permission", Toast.LENGTH_SHORT).show();
				} else startTest(context);

				if (ActivityCompat.checkSelfPermission(context, "android.permission.ACCESS_BACKGROUND_LOCATION") != 0) {
					Toast.makeText(context, "Please grant background location permission", Toast.LENGTH_SHORT).show();
				} else startTest(context);

			} else if (Build.VERSION.SDK_INT == 29) {
				if (ActivityCompat.checkSelfPermission(context, "android.permission.ACCESS_COARSE_LOCATION") != 0 || ActivityCompat.checkSelfPermission(context, "android.permission.ACCESS_FINE_LOCATION") != 0 || ActivityCompat.checkSelfPermission(context, "android.permission.ACCESS_BACKGROUND_LOCATION") != 0) {
					Toast.makeText(context, "Please grant location permission", Toast.LENGTH_SHORT).show();
				}
			} else if (ActivityCompat.checkSelfPermission(context, "android.permission.ACCESS_COARSE_LOCATION") != 0 || ActivityCompat.checkSelfPermission(context, "android.permission.ACCESS_FINE_LOCATION") != 0) {
				Toast.makeText(context, "Please grant location permission", Toast.LENGTH_SHORT).show();
			} else startTest(context);

		}
	}

	private void startTest(Context context) {
		SpeedcheckerSDK.init(context);
		if (!domain.isEmpty() && !ip.isEmpty() && !domain.equals("null") && !ip.equals("null")) {
			Server server = new Server();
			server.Domain = domain;
			server.UserIP = ip;
			SpeedcheckerSDK.SpeedTest.startTest(context, server);
		} else SpeedcheckerSDK.SpeedTest.startTest(context);
	}

	@Override
	public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
	}

	@Override
	public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
		if (call.method.equals("customServer")) {
			domain = call.argument("domain");
			ip = call.argument("ip");
			result.success("Custom server set");
		} else {
			result.notImplemented();
		}
	}
}
