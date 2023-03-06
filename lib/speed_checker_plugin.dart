import 'dart:async';
import 'package:flutter/services.dart';

class SpeedCheckerPlugin {
  static const EventChannel _eventChannel = EventChannel('speedChecker_eventChannel');

  final _speedTestResultController = StreamController<SpeedTestResult>.broadcast();
  Stream<SpeedTestResult> get speedTestResultStream =>
      _speedTestResultController.stream;

  void startSpeedTest() {
    _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is Map<Object?, dynamic>) {
        final result = SpeedTestResult(
          status: event['status']?.toString() ?? '',
          ping: event['ping']?.toInt() ?? 0,
          percent: event['percent']?.toInt() ?? 0,
          currentSpeed: event['currentSpeed']?.toDouble() ?? 0.0,
          downloadSpeed: event['downloadSpeed']?.toDouble() ?? 0.0,
          uploadSpeed: event['uploadSpeed']?.toDouble() ?? 0.0,
          server: event['server']?.toString() ?? '',
          connectionType: event['connectionType']?.toString() ?? '',
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
  final int percent;
  final double currentSpeed;
  final double downloadSpeed;
  final double uploadSpeed;
  final String server;
  final String connectionType;
  final String error;
  final String warning;

  SpeedTestResult({
    required this.status,
    required this.ping,
    required this.percent,
    required this.currentSpeed,
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.server,
    required this.connectionType,
    required this.error,
    required this.warning,
  });

  factory SpeedTestResult.fromJson(Map<Object?, dynamic> json) {
    return SpeedTestResult(
      status: json['status']?.toString() ?? "",
      ping: json['ping']?.toInt() ?? 0,
      percent: json['percent']?.toInt() ?? 0,
      currentSpeed: json['currentSpeed']?.toDouble() ?? 0,
      downloadSpeed: json['downloadSpeed']?.toDouble() ?? 0,
      uploadSpeed: json['uploadSpeed']?.toDouble() ?? 0,
      server: json['server']?.toString() ?? "",
      connectionType: json['connectionType']?.toString() ?? "",
      error: json['error']?.toString() ?? "",
      warning: json['warning']?.toString() ?? "",
    );
  }
}

