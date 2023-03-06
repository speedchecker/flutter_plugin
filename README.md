# SpeedChecker Flutter Plugin

[![pub package](https://img.shields.io/pub/v/speed_checker_plugin)](https://pub.dartlang.org/packages/speed_checker_plugin)

## Free speed test features for your own app

SpeedChecker Flutter plugin allows developers to integrate speed test features into their own flutter apps. You can also try our apps on [Google Play](https://play.google.com/store/apps/details?id=uk.co.broadbandspeedchecker\&hl=en\_US) and [App Store](https://itunes.apple.com/app/id658790195), they are powered by the latest Speedchecker SDK versions. More information about [SpeedChecker SDKs](https://www.speedchecker.com/speed-test-tools/mobile-apps-and-sdks.html)

## Features

* latency, download and upload speed of the user connection
* robust measuring of cellular, wireless and even local network
* testing details like the current speed and progress
* additional information like network type and location (see KPI list below in FAQ)
* included high-capacity servers provided and maintained by [Speedchecker](https://www.speedchecker.com) or custom servers
* detailed statistics and reports by Speedchecker

## Platform Support
| Android | iOS |
|:---:|:---:|
| supported :heavy_check_mark: | supported :heavy_check_mark: |

## Requirements
##### Android

* minSdkVersion 19
* Location permissions

##### iOS

* Xcode 13.3.1 or later
* Swift 5
* Development Target 11.0 or later


## Installation

Add speed_checker_plugin as a [dependency in your pubspec.yaml file](https://flutter.dev/using-packages/).

## Usage

To get speed test results, you need to create an instanse of 'SpeedCheckerPlugin' class, start 'startSpeedTest' method in your class and then listen to 'speedTestResultStream'.

```dart
  String _status = '';
  int _ping = 0;
  String _server = '';
  String _connectionType = '';
  double _currentSpeed = 0;  // real-time value of the current test speed (download or upload)
  int _percent = 0; 		 // real-time value of the current test progress (download or upload)
  double _downloadSpeed = 0;
  double _uploadSpeed = 0;
  String _error = '';
  String _warning = '';
  final _controller = SpeedCheckerPlugin();
```

You can start this method on custom event, such as button click.

```dart
  void getSpeedStats() {
    _controller.startSpeedTest();
    _controller.speedTestResultStream.listen((result) {
      setState(() {
        _status = result.status;
        _ping = result.ping;
        _percent = result.percent;
        _currentSpeed = result.currentSpeed;
        _downloadSpeed = result.downloadSpeed;
        _uploadSpeed = result.uploadSpeed;
        _server = result.server;
        _connectionType = result.connectionType;
        _error = result.error;
        _warning = result.warning;
      });
    });
  }
````

Do not forget to close the stream to prevent memory leaks. It can be done by overriding 'dispose' method

```dart
	@override
	  void dispose() {
		_controller.dispose();
		super.dispose();
	  }
````

## License

SpeedChecker is offering different types of licenses:

| Items                             | Free                          | Basic                                             | Advanced                                                          |
| --------------------------------- | ----------------------------- | ------------------------------------------------- | ----------------------------------------------------------------- |
| Speed Test Metrics                | Download / Upload / Latency   | Download / Upload / Latency / Jitter              | Download / Upload / Latency / Jitter                              |
| Accompanying Metrics              | Device / Network KPIs         | Device / Network KPIs                             | Device / Network KPIs / Advanced Cellular KPIs                    |
| Test Customization                | -                             | test duration, multi-threading, warm-up phase etc | test duration, multi-threading, warm-up phase etc                 |
| Location Permission               | Required location permissions | -                                                 | -                                                                 |
| Data Sharing Requirement          | Required data sharing         | -                                                 | -                                                                 |
| Measurement Servers               | -                             | Custom measurement servers                        | Custom measurement servers                                        |
| Background and passive collection | -                             | -                                                 | Background and Passive data collection                            |
| Cost                              | **FREE**                      | 1,200 EUR per app per year                        | Cost: [**Enquire**](https://www.speedchecker.com/contact-us.html) |

## FAQ

#### **Is the SDK free to use?**

Yes! But the SDK collects data on network performance from your app and shares it with Speedchecker and our clients.The free SDK version requires and enabled location. Those restrictions are not in the Basic and Advanced versions

#### **Does SDK support other types of tests?**

Yes! YouTube video streaming, Voice over IP and other tests are there as well. Check out our [API documentation](https://github.com/speedchecker/speedchecker-sdk-android/wiki/API-documentation)

#### **Do you provide free support?**

No, we provide support only on Basic and Advanced plans

#### **What are all the metrics or KPIs that you can get using our SDKs?**

The free version of the SDK allows getting basic metrics which are described in this [API documentation](https://github.com/speedchecker/speedchecker-sdk-android/wiki/API-documentation)

[Full list of our KPIs for Basic and Advanced versions](https://docs.speedchecker.com/measurement-methodology-links/u21ongNGAYLb6eo7cqjY/kpis-and-measurements/list-of-kpis)

#### **Do you host all infrastructure for the test?**

Yes, you do not need to run any servers. We provide and maintain a network of high-quality servers and CDNs to ensure the testing is accurate. If you wish to configure your own server, this is possible on Basic and Advanced plans.

#### **How do you measure the speed?**

See our [measurement methodology](https://docs.speedchecker.com/measurement-methodology-links/u21ongNGAYLb6eo7cqjY/kpis-and-measurements/data-collection-methodologies)

## What's next?

Please contact us for more details and license requirements. Also, you can download the latest framework version, the sample app to see detailed implementation in the Xcode project as well as our Internet Speed Test application on App Store.

* [More information about SpeedChecker SDKs](https://www.speedchecker.com/speed-test-tools/mobile-apps-and-sdks.html)
* [API documentation](https://github.com/speedchecker/speedchecker-sdk-android/wiki/API-documentation)
* [Buy license](https://www.speedchecker.com/contact-us.html)
* [Contact us](https://www.speedchecker.com/contact-us.html)
