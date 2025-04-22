import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io';

class SpeedCheckerPlugin {
  static const EventChannel _eventChannel = EventChannel(
    'speedChecker_eventChannel',
  );
  static const MethodChannel _methodChannel = MethodChannel(
    'speedChecker_methodChannel',
  );

  final _speedTestResultController =
      StreamController<SpeedTestResult>.broadcast();
  Stream<SpeedTestResult> get speedTestResultStream =>
      _speedTestResultController.stream;

  void startSpeedTest() {
    _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is Map<Object?, dynamic>) {
        final result = SpeedTestResult.fromJson(event);
        _speedTestResultController.add(result);
      }
    });
  }

  void startSpeedTestWithOptions(SpeedTestOptions options) {
    _methodChannel.invokeMethod('speedTestOptions', options.toMap());
    _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is Map<Object?, dynamic>) {
        final result = SpeedTestResult.fromJson(event);
        _speedTestResultController.add(result);
      }
    });
  }

  void startSpeedTestWithServer(SpeedTestServer server) {
    _methodChannel.invokeMethod('customServer', server.toMap());
    _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is Map<Object?, dynamic>) {
        final result = SpeedTestResult.fromJson(event);
        _speedTestResultController.add(result);
      }
    });
  }

  void startSpeedTestWithOptionsAndServer(
    SpeedTestOptions options,
    SpeedTestServer server,
  ) {
    _methodChannel.invokeMethod('speedTestOptions', options.toMap());
    _methodChannel.invokeMethod('customServer', server.toMap());
    _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is Map<Object?, dynamic>) {
        final result = SpeedTestResult.fromJson(event);
        _speedTestResultController.add(result);
      }
    });
  }

  void stopTest() {
    _methodChannel.invokeMethod('stopTest');
  }

  void setAndroidLicenseKey(String license) {
    if (Platform.isAndroid) {
      _methodChannel.invokeMethod('setLicenseKey', {'androidKey': license});
    }
  }

  void setIosLicenseKey(String license) {
    if (Platform.isIOS) {
      _methodChannel.invokeMethod('setLicenseKey', {'iosKey': license});
    }
  }

  @Deprecated('Use startSpeedTestWithServer instead')
  void startSpeedTestWithCustomServer({
    required String domain,
    required String downloadFolderPath,
    required String uploadFolderPath,
    required String city,
    required String country,
    required String countryCode,
    required int id,
  }) {
    startSpeedTestWithServer(
      SpeedTestServer(
        domain: domain,
        downloadFolderPath: downloadFolderPath,
        uploadFolderPath: uploadFolderPath,
        city: city,
        country: country,
        countryCode: countryCode,
        id: id,
      ),
    );
  }

  void dispose() {
    _speedTestResultController.close();
  }
}

class CellularInfo {
  final int? cellId;
  final int? enb;
  final int? localCellId; // Added field for local cell ID (last 8 bits)
  final int? sectorId; // Added field for sector ID (bits 8-13)
  final int? pci;
  final int? tac;
  final int? lac;
  final int? mcc;
  final int? mnc;
  final int? channelNumber;
  final String? type;
  final bool? isFromDataSim;
  final bool? isFromCallSim;
  final int? lteRsrp; // Reference Signal Received Power
  final int? lteRsrq; // Reference Signal Received Quality
  final int? lteSinr; // Signal-to-Noise Ratio (RSSNR in the SDK)
  final int? lteCqi; // Channel Quality Indicator
  final int? nrRsrp; // 5G NR SS Reference Signal Received Power
  final int? nrRsrq; // 5G NR SS Reference Signal Received Quality
  final int? nrSinr; // 5G NR SS Signal-to-Noise and Interference Ratio
  final int? gsmRssi; // GSM Received Signal Level
  final int? wcdmaRscp; // 3G WCDMA CPICH RSCP

  CellularInfo({
    this.cellId,
    this.enb,
    this.localCellId, // Added parameter
    this.sectorId, // Added parameter
    this.pci,
    this.tac,
    this.lac,
    this.mcc,
    this.mnc,
    this.channelNumber,
    this.type,
    this.isFromDataSim,
    this.isFromCallSim,
    this.lteRsrp,
    this.lteRsrq,
    this.lteSinr,
    this.lteCqi,
    this.nrRsrp,
    this.nrRsrq,
    this.nrSinr,
    this.gsmRssi,
    this.wcdmaRscp,
  });

  factory CellularInfo.fromJson(Map<Object?, dynamic> json) {
    return CellularInfo(
      cellId: json['cellId']?.toInt(),
      enb: json['enb']?.toInt(),
      localCellId: json['localCellId']?.toInt(), // Added field
      sectorId: json['sectorId']?.toInt(), // Added field
      pci: json['pci']?.toInt(),
      tac: json['tac']?.toInt(),
      lac: json['lac']?.toInt(),
      mcc: json['mcc']?.toInt(),
      mnc: json['mnc']?.toInt(),
      channelNumber: json['channelNumber']?.toInt(),
      type: json['type']?.toString(),
      isFromDataSim: json['isFromDataSim'],
      isFromCallSim: json['isFromCallSim'],
      lteRsrp: json['lteRsrp']?.toInt(),
      lteRsrq: json['lteRsrq']?.toInt(),
      lteSinr: json['lteSinr']?.toInt(),
      lteCqi: json['lteCqi']?.toInt(),
      nrRsrp: json['nrRsrp']?.toInt(),
      nrRsrq: json['nrRsrq']?.toInt(),
      nrSinr: json['nrSinr']?.toInt(),
      gsmRssi: json['gsmRssi']?.toInt(),
      wcdmaRscp: json['wcdmaRscp']?.toInt(),
    );
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

  // Add cellular info list to support multiple SIMs
  final List<CellularInfo>? cellInfoList;
  final CellCoverageInfo? cellCoverageInfo;

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
    this.ip = '',
    this.isp = '',
    this.cellInfoList,
    this.cellCoverageInfo = null,
  });

  factory SpeedTestResult.fromJson(Map<Object?, dynamic> json) {
    // Create a list of cellular info objects if available
    List<CellularInfo>? cellInfoList;
    if (json['cellInfoList'] != null && json['cellInfoList'] is List) {
      List<dynamic> list = json['cellInfoList'] as List;
      cellInfoList =
          list
              .map(
                (item) => CellularInfo.fromJson(item as Map<Object?, dynamic>),
              )
              .toList();
    }
    // Create a cell coverage info object if available
    CellCoverageInfo? cellCoverageInfo;
    if (json['cellCoverageInfo'] != null) {
      cellCoverageInfo = CellCoverageInfo.fromJson(
        json['cellCoverageInfo'] as Map<Object?, dynamic>,
      );
    }

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
      cellInfoList: cellInfoList,
      cellCoverageInfo: cellCoverageInfo,
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

  const SpeedTestServer({
    required this.domain,
    required this.downloadFolderPath,
    required this.uploadFolderPath,
    required this.city,
    required this.country,
    required this.countryCode,
    required this.id,
  });

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

class CellCoverageInfo {
  final int? rsrp; // Reference Signal Received Power
  final int? rsrq; // Reference Signal Received Quality
  final int? sinr; // Signal-to-Interference-plus-Noise Ratio
  final int? arfcn; // Absolute Radio Frequency Channel Number
  final int? tac; // Tracking Area Code
  final int? pci; // Physical Cell ID
  final int? enbId; // eNodeB ID
  final int? localCellId; // Local Cell ID
  final int? eci; // E-UTRAN Cell Identifier (same as cellId)
  final int? mcc; // Mobile Country Code
  final int? mnc; // Mobile Network Code

  // New fields

  CellCoverageInfo({
    this.pci,
    this.enbId,
    this.localCellId,
    this.eci,
    this.tac,
    this.rsrp,
    this.rsrq,
    this.sinr,
    this.arfcn,
    this.mcc,
    this.mnc,
  });

  factory CellCoverageInfo.fromJson(Map<Object?, dynamic> json) {
    return CellCoverageInfo(
      pci: json['pci']?.toInt(),
      enbId: json['enbId']?.toInt(),
      localCellId: json['localCellId']?.toInt(),
      eci: json['eci']?.toInt(),
      tac: json['tac']?.toInt(),
      rsrp: json['rsrp']?.toInt(),
      rsrq: json['rsrq']?.toInt(),
      sinr: json['sinr']?.toInt(),
      arfcn: json['arfcn']?.toInt(),
    );
  }
}
