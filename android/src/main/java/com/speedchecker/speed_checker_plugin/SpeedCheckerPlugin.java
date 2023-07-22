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
	private static final String METHOD_CHANNEL = "speedChecker_methodChannel";
	private EventChannel.EventSink eventSink;
	private final Map<String, Object> map = new HashMap<>();
	private Context context;
	private Server server = null;
	private boolean isCustomServer = false;

	@Override
	public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
		EventChannel eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), EVENT_CHANNEL);
		MethodChannel channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), METHOD_CHANNEL);
		channel.setMethodCallHandler(this);
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
						map.put("deviceInfo", "");
						map.put("downloadTransferredMb", 0.0);
						map.put("uploadTransferredMb", 0.0);
						map.put("ip", "");
						map.put("isp", "");
						eventSink.success(map);
					}

					@Override
					public void onFetchServerFailed(Integer integer) {

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
						map.put("deviceInfo", speedTestResult.getDeviceInfo());
						map.put("downloadTransferredMb", speedTestResult.getDownloadTransferredMb());
						map.put("uploadTransferredMb", speedTestResult.getUploadTransferredMb());
						map.put("ip", speedTestResult.UserIP);
						map.put("isp", speedTestResult.UserISP);
						isCustomServer = false;
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
						isCustomServer = false;
						eventSink.success(map);
					}

					@Override
					public void onTestInterrupted(String s) {
						map.put("error", s);
						isCustomServer = false;
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
					map.put("error", "Please grant location permission");
					Toast.makeText(context, "Please grant location permission", Toast.LENGTH_SHORT).show();
					eventSink.success(map);
				} else {
					startTest(context);
				}
			} else {
				if (ActivityCompat.checkSelfPermission(context, "android.permission.ACCESS_COARSE_LOCATION") != 0 || ActivityCompat.checkSelfPermission(context, "android.permission.ACCESS_FINE_LOCATION") != 0) {
					map.put("error", "Please grant location permission");
					eventSink.success(map);
				} else {
					startTest(context);
				}
			}
		}
	}


	private void startTest(Context context) {
		SpeedcheckerSDK.init(context);
		if (isCustomServer) {
			SpeedcheckerSDK.SpeedTest.startTest(context, server);
		} else SpeedcheckerSDK.SpeedTest.startTest(context);
	}

	@Override
	public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
	}

	@Override
	public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
		if (call.method.equals("customServer")) {
			isCustomServer = true;
			server = new Server();
			server.Domain = call.argument("domain");
			server.DownloadFolderPath = call.argument("downloadFolderPath");
			server.Id = call.argument("id");
			server.Scheme = "https";
			server.Script = "php";
			server.UploadFolderPath = call.argument("uploadFolderPath");
			server.Version = 3;
			server.Location = server.new Location();
			server.Location.City = call.argument("city");
			server.Location.Country = call.argument("country");
			server.Location.CountryCode = call.argument("countryCode");
			result.success("Custom server set");
		} else if (call.method.equals("stopTest")) {
			SpeedcheckerSDK.SpeedTest.interruptTest();
			map.put("status", "Speed test stopped");
			eventSink.success(map);
		} else {
			result.notImplemented();
		}
	}
}
