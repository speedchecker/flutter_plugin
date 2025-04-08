package com.speedchecker.speed_checker_plugin;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.speedchecker.android.sdk.Public.Server;
import com.speedchecker.android.sdk.Public.SpeedTestListener;
import com.speedchecker.android.sdk.Public.SpeedTestOptions;
import com.speedchecker.android.sdk.Public.SpeedTestResult;
import com.speedchecker.android.sdk.SpeedcheckerSDK;
import com.speedchecker.android.sdk.Public.Model.SCellInfo; // Updated import path

import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class SpeedCheckerPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private static final String TAG = "SpeedCheckerPlugin";
    private static final String EVENT_CHANNEL = "speedChecker_eventChannel";
    private static final String METHOD_CHANNEL = "speedChecker_methodChannel";

    private EventChannel eventChannel;
    private MethodChannel methodChannel;
    private EventChannel.EventSink eventSink;
    private final Map<String, Object> map = new HashMap<>();
    private WeakReference<Context> contextRef;
    private Server server = null;
    private boolean isCustomServer = false;
    private SpeedTestOptions speedTestOptions = null;
    private SpeedTestListener speedTestListener;

    // ================== FlutterPlugin Lifecycle ================== //

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {

        Log.d(TAG, "onAttachedToEngine");
        contextRef = new WeakReference<>(flutterPluginBinding.getApplicationContext());

        // Initialize channels
        eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), EVENT_CHANNEL);
        methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), METHOD_CHANNEL);

        eventChannel.setStreamHandler(this);
        methodChannel.setMethodCallHandler(this);

        // Initialize the SDK
        Context context = getContext();
        if (context != null) {
            SpeedcheckerSDK.init(context);
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        Log.d(TAG, "onDetachedFromEngine");
        cleanup();
    }

    private void cleanup() {
        if (eventChannel != null) {
            eventChannel.setStreamHandler(null);
            eventChannel = null;
        }
        if (methodChannel != null) {
            methodChannel.setMethodCallHandler(null);
            methodChannel = null;
        }
        
        // Interrupt any active test and remove listener
        try {
            SpeedcheckerSDK.SpeedTest.interruptTest();
            SpeedcheckerSDK.SpeedTest.setOnSpeedTestListener(null);
        } catch (Exception e) {
            Log.e(TAG, "Error during cleanup", e);
        }
        
        contextRef = null;
        eventSink = null;
        speedTestListener = null;
        clearState();
    }

    // ================== EventChannel.StreamHandler ================== //

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        Log.d(TAG, "onListen");
        this.eventSink = events;
        this.speedTestListener = createSpeedTestListener();
        
        try {
            // Set the listener on SpeedTest
            SpeedcheckerSDK.SpeedTest.setOnSpeedTestListener(speedTestListener);
            
            // Start the test
            checkPermissionAndStartTest();
        } catch (Exception e) {
            Log.e(TAG, "Error in onListen", e);
            if (events != null) {
                Map<String, Object> errorMap = new HashMap<>();
                errorMap.put("error", "Failed to set listener: " + e.getMessage());
                events.success(errorMap);
            }
        }
    }

    @Override
    public void onCancel(Object arguments) {
        Log.d(TAG, "onCancel");
        
        try {
            // Remove the listener
            SpeedcheckerSDK.SpeedTest.setOnSpeedTestListener(null);
        } catch (Exception e) {
            Log.e(TAG, "Error removing listener", e);
        }
        
        this.eventSink = null;
        this.speedTestListener = null;
    }

    // ================== MethodChannel.MethodCallHandler ================== //

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        try {
            Log.d(TAG, "onMethodCall: " + call.method);
            switch (call.method) {
                case "customServer":
                    handleCustomServer(call, result);
                    break;
                case "stopTest":
                    handleStopTest(result);
                    break;
                case "speedTestOptions":
                    handleSpeedTestOptions(call, result);
                    break;
                default:
                    result.notImplemented();
            }
        } catch (Exception e) {
            Log.e(TAG, "Error in onMethodCall", e);
            result.error("ERROR", e.getMessage(), null);
        }
    }

    private void handleCustomServer(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
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
    }

    private void handleStopTest(@NonNull MethodChannel.Result result) {
        try {
            // Interrupt the test
            SpeedcheckerSDK.SpeedTest.interruptTest();
            
            if (eventSink != null) {
                synchronized (map) {
                    map.put("status", "Speed test stopped");
                }
                sendEvent();
            }
            result.success(null);
        } catch (Exception e) {
            Log.e(TAG, "Error stopping test", e);
            result.error("ERROR", "Failed to stop test: " + e.getMessage(), null);
        }
    }

    private void handleSpeedTestOptions(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        speedTestOptions = new SpeedTestOptions();
        Boolean sendResults = call.argument("sendResultsToSpeedChecker");
        speedTestOptions.setSendResultsToSpeedChecker(sendResults != null && sendResults);
        result.success(null);
    }

    // ================== SpeedTestListener Implementation ================== //

    private SpeedTestListener createSpeedTestListener() {
        return new SpeedTestListener() {
            @Override
            public void onTestStarted() {
                Log.d(TAG, "onTestStarted");
                synchronized (map) {
                    map.clear();
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
                }
                sendEvent();
            }

            @Override
            public void onFetchServerFailed(Integer errorCode) {
                Log.e(TAG, "onFetchServerFailed: " + errorCode);
                synchronized (map) {
                    map.put("error", "Server fetch failed: " + errorCode);
                }
                sendEvent();
            }

            @Override
            public void onFindingBestServerStarted() {
                Log.d(TAG, "onFindingBestServerStarted");
                synchronized (map) {
                    map.put("status", "Finding best server");
                }
                sendEvent();
            }

            @Override
            public void onTestFinished(SpeedTestResult speedTestResult) {
                Log.d(TAG, "onTestFinished");
                synchronized (map) {
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
                    
                    // Get IP and ISP information
                    map.put("ip", speedTestResult.UserIP != null ? speedTestResult.UserIP : "");
                    map.put("isp", speedTestResult.UserISP != null ? speedTestResult.UserISP : "");
                    
                    // Add cellular information if available
                    try {
                        List<SCellInfo> cellInfoList = speedTestResult.getsCellInfoList();
                        if (cellInfoList != null && !cellInfoList.isEmpty()) {
                            List<Map<String, Object>> cellMapList = new ArrayList<>();
                            
                            for (SCellInfo cellInfo : cellInfoList) {
                                Map<String, Object> cellMap = new HashMap<>();
                                
                                cellMap.put("cellId", cellInfo.getCellId());
                                // eNodeB ID calculation (first 28 bits of the cell ID for LTE)
                                long cellId = cellInfo.getCellId();
                                cellMap.put("enb", cellId >> 8);
                                
                                // Use the exact method names from the SCellInfo class
                                try { cellMap.put("pci", cellInfo.getLtePci()); } catch (Exception e) { }
                                try { cellMap.put("tac", cellInfo.getTAC()); } catch (Exception e) { }
                                try { cellMap.put("lac", cellInfo.getLAC()); } catch (Exception e) { }
                                try { cellMap.put("mcc", cellInfo.getMCC()); } catch (Exception e) { }
                                try { cellMap.put("mnc", cellInfo.getMNC()); } catch (Exception e) { }
                                try { cellMap.put("channelNumber", cellInfo.getChannelNumber()); } catch (Exception e) { }
                                try { cellMap.put("type", cellInfo.getType()); } catch (Exception e) { }
                                try { cellMap.put("isFromDataSim", cellInfo.isFromDataSim()); } catch (Exception e) { }
                                try { cellMap.put("isFromCallSim", cellInfo.isFromCallSim()); } catch (Exception e) { }
                                
                                // LTE signal metrics
                                try { cellMap.put("lteRsrp", cellInfo.getLteRSRP()); } catch (Exception e) { }
                                try { cellMap.put("lteRsrq", cellInfo.getLteRSRQ()); } catch (Exception e) { }
                                try { cellMap.put("lteSinr", cellInfo.getLteRSSNR()); } catch (Exception e) { }
                                try { cellMap.put("lteCqi", cellInfo.getLteCQI()); } catch (Exception e) { }
                                try { cellMap.put("lteRssi", cellInfo.getLteRssi()); } catch (Exception e) { }
                                try { cellMap.put("lteTimingAdvance", cellInfo.getLteTimingAdvance()); } catch (Exception e) { }
                                
                                // 5G signal metrics
                                try { cellMap.put("nrRsrp", cellInfo.getNrRSRP()); } catch (Exception e) { }
                                try { cellMap.put("nrRsrq", cellInfo.getNrRSRQ()); } catch (Exception e) { }
                                try { cellMap.put("nrSinr", cellInfo.getNrSINR()); } catch (Exception e) { }
                                
                                // 2G/3G signal metrics
                                try { cellMap.put("gsmRssi", cellInfo.getGsmRSSI()); } catch (Exception e) { }
                                try { cellMap.put("gsmBer", cellInfo.getGsmBer()); } catch (Exception e) { }
                                try { cellMap.put("wcdmaRscp", cellInfo.getWcdmaRSCP()); } catch (Exception e) { }
                                try { cellMap.put("wcdmaPsc", cellInfo.getWcdmaPsc()); } catch (Exception e) { }
                                try { cellMap.put("wcdmaEcNo", cellInfo.getWcdmaEcNo()); } catch (Exception e) { }
                                
                                // Additional information
                                try { cellMap.put("isRoaming", cellInfo.isRoaming()); } catch (Exception e) { }
                                try { 
                                    int[] bandwidths = cellInfo.getCellBandwidths();
                                    if (bandwidths != null) {
                                        cellMap.put("cellBandwidths", bandwidths);
                                    }
                                } catch (Exception e) { }
                                
                                try { cellMap.put("networkOperator", cellInfo.getNetworkOperator()); } catch (Exception e) { }
                                try { cellMap.put("networkOperatorName", cellInfo.getNetworkOperatorName()); } catch (Exception e) { }
                                try { cellMap.put("simOperator", cellInfo.getSimOperator()); } catch (Exception e) { }
                                try { cellMap.put("simOperatorName", cellInfo.getSimOperatorName()); } catch (Exception e) { }
                                
                                cellMapList.add(cellMap);
                            }
                            
                            map.put("cellInfoList", cellMapList);
                        }
                    } catch (Exception e) {
                        Log.e(TAG, "Error processing cell info", e);
                    }
                }
                sendEvent();
                clearState();
            }

            @Override
            public void onPingStarted() {
                Log.d(TAG, "onPingStarted");
                synchronized (map) {
                    map.put("status", "Ping");
                }
                sendEvent();
            }

            @Override
            public void onPingFinished(int ping, int jitter) {
                Log.d(TAG, "onPingFinished: " + ping + " ms, jitter: " + jitter + " ms");
                synchronized (map) {
                    map.put("ping", ping);
                    map.put("jitter", jitter);
                }
                sendEvent();
            }

            @Override
            public void onDownloadTestStarted() {
                Log.d(TAG, "onDownloadTestStarted");
                synchronized (map) {
                    map.put("status", "Download");
                }
                sendEvent();
            }

            @Override
            public void onDownloadTestProgress(int percent, double speedMbs, double transferredMb) {
                synchronized (map) {
                    map.put("percent", percent);
                    map.put("currentSpeed", speedMbs);
                    map.put("downloadTransferredMb", transferredMb);
                }
                sendEvent();
            }

            @Override
            public void onDownloadTestFinished(double speedMbs) {
                Log.d(TAG, "onDownloadTestFinished: " + speedMbs + " Mbps");
                synchronized (map) {
                    map.put("downloadSpeed", speedMbs);
                }
                sendEvent();
            }

            @Override
            public void onUploadTestStarted() {
                Log.d(TAG, "onUploadTestStarted");
                synchronized (map) {
                    map.put("status", "Upload");
                    map.put("currentSpeed", 0);
                    map.put("percent", 0);
                }
                sendEvent();
            }

            @Override
            public void onUploadTestProgress(int percent, double speedMbs, double transferredMb) {
                synchronized (map) {
                    map.put("percent", percent);
                    map.put("currentSpeed", speedMbs);
                    map.put("uploadTransferredMb", transferredMb);
                }
                sendEvent();
            }

            @Override
            public void onUploadTestFinished(double speedMbs) {
                Log.d(TAG, "onUploadTestFinished: " + speedMbs + " Mbps");
                synchronized (map) {
                    map.put("uploadSpeed", speedMbs);
                }
                sendEvent();
            }

            @Override
            public void onTestWarning(String warning) {
                Log.w(TAG, "onTestWarning: " + warning);
                synchronized (map) {
                    map.put("warning", warning);
                }
                sendEvent();
            }

            @Override
            public void onTestFatalError(String error) {
                Log.e(TAG, "onTestFatalError: " + error);
                synchronized (map) {
                    map.put("error", error);
                }
                clearState();
                sendEvent();
            }

            @Override
            public void onTestInterrupted(String reason) {
                Log.w(TAG, "onTestInterrupted: " + reason);
                synchronized (map) {
                    map.put("error", reason);
                }
                clearState();
                sendEvent();
            }
        };
    }

    // ================== Helper Methods ================== //

    private void sendEvent() {
        if (eventSink != null) {
            try {
                Map<String, Object> eventData;
                synchronized (map) {
                    eventData = new HashMap<>(map); // Thread-safe copy
                }
                eventSink.success(eventData);
            } catch (Exception e) {
                Log.e(TAG, "Failed to send event", e);
            }
        }
    }

    private void clearState() {
        synchronized (map) {
            map.clear();
        }
        server = null;
        isCustomServer = false;
        speedTestOptions = null;
    }

    private Context getContext() {
        return contextRef != null ? contextRef.get() : null;
    }

    private void checkPermissionAndStartTest() {
        Context context = getContext();
        if (context == null) {
            Log.e(TAG, "Context is null");
            return;
        }

        // Make sure SDK is initialized
        SpeedcheckerSDK.init(context);
        
        try {
            // Start the test based on the options
            if (speedTestOptions != null && isCustomServer) {
                SpeedcheckerSDK.SpeedTest.startTest(context, server, speedTestOptions);
            } else if (isCustomServer) {
                SpeedcheckerSDK.SpeedTest.startTest(context, server);
            } else {
                SpeedcheckerSDK.SpeedTest.startTest(context);
            }
            
            Log.d(TAG, "Speed test started successfully");
        } catch (Exception e) {
            Log.e(TAG, "Error starting test", e);
            if (eventSink != null) {
                synchronized (map) {
                    map.put("error", "Failed to start test: " + e.getMessage());
                }
                sendEvent();
            }
        }
    }
}