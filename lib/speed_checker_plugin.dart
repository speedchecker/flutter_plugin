import 'dart:async';
import 'package:flutter/services.dart';

class SpeedCheckerPlugin {
  static const EventChannel _eventChannel = EventChannel('speedChecker_eventChannel');
  static const MethodChannel _methodChannel = MethodChannel('speedChecker_methodChannel');

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
          deviceInfo: event['deviceInfo']?.toString() ?? '',
          downloadTransferredMb: event['downloadTransferredMb']?.toDouble() ?? 0.0,
          uploadTransferredMb: event['uploadTransferredMb']?.toDouble() ?? 0.0,
          error: event['error']?.toString() ?? '',
          warning: event['warning']?.toString() ?? '',
        );
        _speedTestResultController.add(result);
      }
    });
  }

  void stopTest() {
    _methodChannel.invokeMethod('stopTest');
  }

  void getIpInfo() {

  }

  void startSpeedTestWithCustomServer(
      {required String domain,
      required String downloadFolderPath,
      required String uploadFolderPath,
      required String city,
      required String country,
      required String countryCode,
      required int id}) {
    _methodChannel.invokeMethod('customServer', {
      'domain': domain,
      'downloadFolderPath': downloadFolderPath,
      'uploadFolderPath': uploadFolderPath,
      'city': city,
      'country': country,
      'countryCode': countryCode,
      'id': id
    });
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
          deviceInfo: event['deviceInfo']?.toString() ?? '',
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
  final String deviceInfo;
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
    this.deviceInfo = '',
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
      deviceInfo: json['deviceInfo']?.toString() ?? "",
      downloadTransferredMb: json['downloadTransferredMb']?.toDouble() ?? 0,
      uploadTransferredMb: json['uploadTransferredMb']?.toDouble() ?? 0,
      error: json['error']?.toString() ?? "",
      warning: json['warning']?.toString() ?? "",
    );
  }
}
