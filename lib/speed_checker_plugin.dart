import 'dart:async';
import 'package:flutter/services.dart';

class SpeedCheckerPlugin {
  static const EventChannel _eventChannel = EventChannel('speedChecker_eventChannel');

  final _speedTestResultController = StreamController<SpeedTestResult>.broadcast();

  Stream<SpeedTestResult> get speedTestResultStream => _speedTestResultController.stream;

  void startSpeedTest() {
    _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is Map<Object?, dynamic>) {
        final result = SpeedTestResult(
          status: event['status']?.toString() ?? '',
          ping: event['ping']?.toInt() ?? 0,
          jitter: event['jitter']?.toInt() ?? 0,
          percent: event['percent']?.toInt() ?? 0,
          currentSpeed: event['currentSpeed']?.toDouble() ?? 0.0,
          downloadSpeed: event['downloadSpeed']?.toDouble() ?? 0.0,
          uploadSpeed: event['uploadSpeed']?.toDouble() ?? 0.0,
          server: event['server']?.toString() ?? '',
          connectionType: event['connectionType']?.toString() ?? '',
          serverInfo: event['serverInfo']?.toString() ?? '',
          locationLatitude: event['locationLatitude']?.toDouble() ?? 0.0,
          locationLongitude: event['locationLongitude']?.toDouble() ?? 0.0,
          locationAccuracy: event['locationAccuracy']?.toDouble() ?? 0.0,
          deviceInfo: event['deviceInfo']?.toString() ?? '',
          cityName: event['cityName']?.toString() ?? '',
          downloadTransferredMb: event['downloadTransferredMb']?.toDouble() ?? 0.0,
          uploadTransferredMb: event['uploadTransferredMb']?.toDouble() ?? 0.0,
          error: event['error']?.toString() ?? '',
          warning: event['warning']?.toString() ?? '',
        );
        _speedTestResultController.add(result);
      }
    });
  }

  void startSpeedTestWithCustomServer(String domain, String ip) {
    const MethodChannel('speedChecker_methodChannel').invokeMethod('customServer', {'domain': domain, 'ip': ip});
    _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is Map<Object?, dynamic>) {
        final result = SpeedTestResult(
          status: event['status']?.toString() ?? '',
          ping: event['ping']?.toInt() ?? 0,
          jitter: event['jitter']?.toInt() ?? 0,
          percent: event['percent']?.toInt() ?? 0,
          currentSpeed: event['currentSpeed']?.toDouble() ?? 0.0,
          downloadSpeed: event['downloadSpeed']?.toDouble() ?? 0.0,
          uploadSpeed: event['uploadSpeed']?.toDouble() ?? 0.0,
          server: event['server']?.toString() ?? '',
          connectionType: event['connectionType']?.toString() ?? '',
          serverInfo: event['serverInfo']?.toString() ?? '',
          locationLatitude: event['locationLatitude']?.toDouble() ?? 0.0,
          locationLongitude: event['locationLongitude']?.toDouble() ?? 0.0,
          locationAccuracy: event['locationAccuracy']?.toDouble() ?? 0.0,
          deviceInfo: event['deviceInfo']?.toString() ?? '',
          cityName: event['cityName']?.toString() ?? '',
          downloadTransferredMb: event['downloadTransferredMb']?.toDouble() ?? 0.0,
          uploadTransferredMb: event['uploadTransferredMb']?.toDouble() ?? 0.0,
          error: event['error']?.toString() ?? '',
          warning: event['warning']?.toString() ?? '',
        );
        _speedTestResultController.add(result);
      }
    });
  }

  void dispose() {
    _speedTestResultController.close();
  }
}

class SpeedTestResult {
  final String status;
  final int ping;
  final int jitter;
  final int percent;
  final double currentSpeed;
  final double downloadSpeed;
  final double uploadSpeed;
  final String server;
  final String connectionType;
  final String serverInfo;
  final double locationLatitude;
  final double locationLongitude;
  final double locationAccuracy;
  final String deviceInfo;
  final String cityName;
  final double downloadTransferredMb;
  final double uploadTransferredMb;
  final String error;
  final String warning;

  SpeedTestResult({
    this.status = '',
    this.ping = 0,
    this.jitter = 0,
    this.percent = 0,
    this.currentSpeed = 0.0,
    this.downloadSpeed = 0.0,
    this.uploadSpeed = 0.0,
    this.server = '',
    this.connectionType = '',
    this.serverInfo = '',
    this.locationLatitude = 0.0,
    this.locationLongitude = 0.0,
    this.locationAccuracy = 0.0,
    this.deviceInfo = '',
    this.cityName = '',
    this.downloadTransferredMb = 0.0,
    this.uploadTransferredMb = 0.0,
    this.error = '',
    this.warning = '',
  });

  factory SpeedTestResult.fromJson(Map<Object?, dynamic> json) {
    return SpeedTestResult(
      status: json['status']?.toString() ?? "",
      ping: json['ping']?.toInt() ?? 0,
      jitter: json['jitter']?.toInt() ?? 0,
      percent: json['percent']?.toInt() ?? 0,
      currentSpeed: json['currentSpeed']?.toDouble() ?? 0,
      downloadSpeed: json['downloadSpeed']?.toDouble() ?? 0,
      uploadSpeed: json['uploadSpeed']?.toDouble() ?? 0,
      server: json['server']?.toString() ?? "",
      connectionType: json['connectionType']?.toString() ?? "",
      serverInfo: json['serverInfo']?.toString() ?? "",
      locationLatitude: json['locationLatitude']?.toDouble() ?? 0,
      locationLongitude: json['locationLongitude']?.toDouble() ?? 0,
      locationAccuracy: json['locationAccuracy']?.toDouble() ?? 0,
      deviceInfo: json['deviceInfo']?.toString() ?? "",
      cityName: json['cityName']?.toString() ?? "",
      downloadTransferredMb: json['downloadTransferredMb']?.toDouble() ?? 0,
      uploadTransferredMb: json['uploadTransferredMb']?.toDouble() ?? 0,
      error: json['error']?.toString() ?? "",
      warning: json['warning']?.toString() ?? "",
    );
  }
}
