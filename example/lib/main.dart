import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speed_checker_plugin/speed_checker_plugin.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const int backgroundColor = 0xFFE5E5E5;

  String _status = '';
  int _ping = 0;
  String _server = '';
  String _connectionType = '';
  double _currentSpeed = 0;
  int _percent = 0;
  double _downloadSpeed = 0;
  double _uploadSpeed = 0;
  String _ip = '';
  String _isp = '';
  final _plugin = SpeedCheckerPlugin();
  late StreamSubscription<SpeedTestResult> _subscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _plugin.dispose();
    super.dispose();
  }

  void getSpeedStats() {
    _plugin.startSpeedTest();
    _subscription = _plugin.speedTestResultStream.listen((result) {
      setState(() {
        _status = result.status;
        _ping = result.ping;
        _percent = result.percent;
        _currentSpeed = result.currentSpeed;
        _downloadSpeed = result.downloadSpeed;
        _uploadSpeed = result.uploadSpeed;
        _server = result.server;
        _connectionType = result.connectionType;
        _ip = result.ip;
        _isp = result.isp;
      });
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      _status = error.toString();
      _subscription.cancel();
    });
  }

  void stopTest() {
    _plugin.stopTest();
    _subscription = _plugin.speedTestResultStream.listen((result) {
      setState(() {
        _status = "Speed test stopped";
        _ping = 0;
        _percent = 0;
        _currentSpeed = 0;
        _downloadSpeed = 0;
        _uploadSpeed = 0;
        _server = '';
        _connectionType = '';
        _ip = '';
        _isp = '';
      });
    }, onDone: () {
      _subscription.cancel();
    });
  }

  void getCustomSpeedStats() {
    _plugin.startSpeedTestWithCustomServer(
        domain: 'dig20ny.speedcheckerapi.com',
        downloadFolderPath: '/',
        uploadFolderPath: '/',
        city: 'New York 2',
        country: 'USA',
        countryCode: 'US',
        id: 104);

    _subscription = _plugin.speedTestResultStream.listen((result) {
      setState(() {
        _status = result.status;
        _ping = result.ping;
        _percent = result.percent;
        _currentSpeed = result.currentSpeed;
        _downloadSpeed = result.downloadSpeed;
        _uploadSpeed = result.uploadSpeed;
        _server = result.server;
        _connectionType = result.connectionType;
        _ip = result.ip;
        _isp = result.isp;
        if (result.error == 'Connection timeout. DOWNLOAD stage') {
          _status = result.error.toString();
        } else if (result.error == 'Connection timeout. UPLOAD stage') {
          _status = result.error.toString();
        }
      });
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      _status = error.toString();
      _subscription.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Speed Checker flutter plugin demo app'),
        ),
        body: Container(
          color: const Color(backgroundColor).withOpacity(0.5),
          child: Center(
            child: Column(
              children: [
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(_status,
                        style:
                            const TextStyle(fontSize: 15, color: Color(SpeedMeter.mainRedColor)))),
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 50),
                  child: SpeedMeter(currentSpeed: _currentSpeed, percent: _percent),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                        onPressed: getSpeedStats,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(SpeedMeter.mainRedColor),
                            textStyle: const TextStyle(fontSize: 16)),
                        child: Text(
                          "start test".toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                        onPressed: getCustomSpeedStats,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(SpeedMeter.mainRedColor),
                            textStyle: const TextStyle(fontSize: 16)),
                        child: Text(
                          "start custom test".toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    onPressed: stopTest,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(SpeedMeter.mainRedColor),
                        textStyle: const TextStyle(fontSize: 16)),
                    child: Text(
                      "stop test".toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('Speed test results'.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(SpeedMeter.blackTextColor))),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.only(left: 50),
                  child: Wrap(
                    direction: Axis.vertical,
                    spacing: 5,
                    children: [
                      Text(
                        'Server: $_server',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Ping: $_ping',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Download speed: ${_downloadSpeed.toStringAsFixed(2)} Mbps',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Upload speed: ${_uploadSpeed.toStringAsFixed(2)} Mbps',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Connection Type: $_connectionType',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'User IP: $_ip',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'User ISP: $_isp',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SpeedMeter extends StatelessWidget {
  final double maxValue = 100;
  final double currentSpeed;
  final int percent;
  final double thickness = 20;

  static const int mainRedColor = 0xFFAF0017;
  static const int startProgressColor = 0xFFE53032;
  static const int endProgressColor = 0xFF960C0E;
  static const int tickColor = 0xFF999999;
  static const int greyCircleColor = 0xFFE7E7E6;
  static const int blackTextColor = 0xFF333333;

  const SpeedMeter({super.key, this.currentSpeed = 100, this.percent = 50});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Stack(
      children: [
        Positioned(
          bottom: 0,
          right: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(currentSpeed.toStringAsFixed(2),
                  style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.8,
                      color: Color(mainRedColor))),
              const Text('Mbps',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold, color: Color(blackTextColor))),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Progress: '.toUpperCase(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: -0.8,
                            color: Color(blackTextColor)),
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          "${percent.round()}%",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(mainRedColor)),
                        ),
                      )
                    ]),
              ),
              Container(
                width: 100,
                margin: const EdgeInsets.only(top: 3),
                child: SfLinearGauge(
                  showLabels: false,
                  showTicks: false,
                  showAxisTrack: true,
                  axisTrackStyle: LinearAxisTrackStyle(
                    thickness: thickness,
                    edgeStyle: LinearEdgeStyle.bothCurve,
                    color: Colors.white,
                  ),
                  barPointers: [
                    LinearBarPointer(
                      value: percent.toDouble(),
                      thickness: thickness,
                      edgeStyle: LinearEdgeStyle.bothCurve,
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                            colors: [Color(startProgressColor), Color(endProgressColor)],
                            stops: [0.0, 1.0]).createShader(bounds);
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(
          width: 230,
          height: 230,
          child: SfRadialGauge(
            axes: [
              RadialAxis(
                radiusFactor: 1,
                showLabels: false,
                showTicks: false,
                maximum: maxValue,
                startAngle: 90,
                endAngle: 360,
                axisLineStyle: AxisLineStyle(
                  thickness: thickness,
                  cornerStyle: CornerStyle.endCurve,
                  color: Colors.white,
                ),
                pointers: <GaugePointer>[
                  RangePointer(
                    value: currentSpeed,
                    width: thickness,
                    cornerStyle: CornerStyle.endCurve,
                    sizeUnit: GaugeSizeUnit.logicalPixel,
                    enableAnimation: true,
                    gradient: const SweepGradient(
                      colors: [Color(startProgressColor), Color(endProgressColor)],
                      stops: <double>[0.0, 1.0],
                    ),
                  ),
                ],
              ),
              RadialAxis(
                showAxisLine: false,
                showLabels: false,
                showTicks: false,
                startAngle: 180,
                endAngle: 360,
                radiusFactor: 0.75,
                ranges: [
                  GaugeRange(
                    startValue: 0,
                    endValue: 100,
                    startWidth: 0,
                    endWidth: thickness * 1.4,
                    color: const Color(greyCircleColor),
                  )
                ],
              ),
              RadialAxis(
                radiusFactor: 1.2,
                showAxisLine: false,
                showLabels: false,
                showTicks: true,
                maximum: 270,
                startAngle: 90,
                endAngle: 360,
                interval: 90,
                majorTickStyle: MajorTickStyle(
                    length: thickness / 2, thickness: thickness / 4, color: const Color(tickColor)),
                minorTicksPerInterval: 8,
                tickOffset: thickness * 0.7,
                ticksPosition: ElementsPosition.outside,
                minorTickStyle: MinorTickStyle(thickness: thickness / 8),
              )
            ],
          ),
        )
      ],
    ));
  }
}
