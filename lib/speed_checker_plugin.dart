import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io';

class SpeedCheckerPlugin {
  static const EventChannel _eventChannel =
      EventChannel('speedChecker_eventChannel');
  static const MethodChannel _methodChannel =
      MethodChannel('speedChecker_methodChannel');

  final _speedTestResultController =
      StreamController<SpeedTestResult>.broadcast();

  Stream<SpeedTestResult> get speedTestResultStream =>
      _speedTestResultController.stream;

  void startSpeedTest() {
    _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is Map<Object?, dynamic>) {
        final result = SpeedTestResult.fromJson(event);
        if (!_speedTestResultController.isClosed) {
          _speedTestResultController.add(result);
        }
      }
    });
  }

  void startSpeedTestWithOptions(SpeedTestOptions options) {
    _methodChannel.invokeMethod('speedTestOptions', options.toMap());
    _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is Map<Object?, dynamic>) {
        final result = SpeedTestResult.fromJson(event);
        if (!_speedTestResultController.isClosed) {
          _speedTestResultController.add(result);
        }
      }
    });
  }

  void startSpeedTestWithServer(SpeedTestServer server) {
    _methodChannel.invokeMethod('customServer', server.toMap());
    _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is Map<Object?, dynamic>) {
        final result = SpeedTestResult.fromJson(event);
        if (!_speedTestResultController.isClosed) {
          _speedTestResultController.add(result);
        }
      }
    });
  }

  void startSpeedTestWithOptionsAndServer(
      SpeedTestOptions options, SpeedTestServer server) {
    _methodChannel.invokeMethod('speedTestOptions', options.toMap());
    _methodChannel.invokeMethod('customServer', server.toMap());
    _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is Map<Object?, dynamic>) {
        final result = SpeedTestResult.fromJson(event);
        if (!_speedTestResultController.isClosed) {
          _speedTestResultController.add(result);
        }
      }
    });
  }

  void stopTest() {
    _methodChannel.invokeMethod('stopTest');
  }

  void setIosLicenseKey(String license) {
    if (Platform.isIOS) {
      _methodChannel.invokeMethod('setLicenseKey', {'iosKey': license});
    }
  }

  @Deprecated('Use startSpeedTestWithServer instead')
  void startSpeedTestWithCustomServer(
      {required String domain,
      required String downloadFolderPath,
      required String uploadFolderPath,
      required String city,
      required String country,
      required String countryCode,
      required int id}) {
    startSpeedTestWithServer(SpeedTestServer(
        domain: domain,
        downloadFolderPath: downloadFolderPath,
        uploadFolderPath: uploadFolderPath,
        city: city,
        country: country,
        countryCode: countryCode,
        id: id));
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
  final String ip;
  final String isp;
  final String packetLoss;

  SpeedTestResult(
      {this.status = '',
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
      this.ip = '',
      this.isp = '',
      this.packetLoss = ''});

  factory SpeedTestResult.fromJson(Map<Object?, dynamic> json) {
    return SpeedTestResult(
      status: json['status']?.toString() ?? '',
      ping: json['ping']?.toInt() ?? 0,
      jitter: json['jitter']?.toInt() ?? 0,
      percent: json['percent']?.toInt() ?? 0,
      currentSpeed: json['currentSpeed']?.toDouble() ?? 0.0,
      downloadSpeed: json['downloadSpeed']?.toDouble() ?? 0.0,
      uploadSpeed: json['uploadSpeed']?.toDouble() ?? 0.0,
      server: json['server']?.toString() ?? '',
      connectionType: json['connectionType']?.toString() ?? '',
      serverInfo: json['serverInfo']?.toString() ?? '',
      deviceInfo: json['deviceInfo']?.toString() ?? '',
      downloadTransferredMb: json['downloadTransferredMb']?.toDouble() ?? 0.0,
      uploadTransferredMb: json['uploadTransferredMb']?.toDouble() ?? 0.0,
      error: json['error']?.toString() ?? '',
      warning: json['warning']?.toString() ?? '',
      ip: json['ip']?.toString() ?? '',
      isp: json['isp']?.toString() ?? '',
      packetLoss: json['packetLoss']?.toString() ?? '',
    );
  }
}

class SpeedTestOptions {
  final int? downloadTimeMs;
  final int? uploadTimeMs;
  final int? downloadThreadsCount;
  final int? uploadThreadsCount;
  final int? additionalThreadsCount;
  final int? connectionTimeoutMs;
  final bool? sendResultsToSpeedChecker;

  const SpeedTestOptions({
    this.downloadTimeMs,
    this.uploadTimeMs,
    this.downloadThreadsCount,
    this.uploadThreadsCount,
    this.additionalThreadsCount,
    this.connectionTimeoutMs,
    this.sendResultsToSpeedChecker,
  });

  Map<String, dynamic> toMap() {
    return {
      'downloadTimeMs': downloadTimeMs,
      'uploadTimeMs': uploadTimeMs,
      'downloadThreadsCount': downloadThreadsCount,
      'uploadThreadsCount': uploadThreadsCount,
      'additionalThreadsCount': additionalThreadsCount,
      'connectionTimeoutMs': connectionTimeoutMs,
      'sendResultsToSpeedChecker': sendResultsToSpeedChecker,
    };
  }
}

class SpeedTestServer {
  final String domain;
  final String downloadFolderPath;
  final String uploadFolderPath;
  final String city;
  final String country;
  final String countryCode;
  final int id;

  const SpeedTestServer(
      {required this.domain,
      required this.downloadFolderPath,
      required this.uploadFolderPath,
      required this.city,
      required this.country,
      required this.countryCode,
      required this.id});

  Map<String, dynamic> toMap() {
    return {
      'domain': domain,
      'downloadFolderPath': downloadFolderPath,
      'uploadFolderPath': uploadFolderPath,
      'city': city,
      'country': country,
      'countryCode': countryCode,
      'id': id,
    };
  }
}
