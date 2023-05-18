# SpeedChecker Flutter Plugin

[![pub package](https://img.shields.io/pub/v/speed_checker_plugin)](https://pub.dartlang.org/packages/speed_checker_plugin)

## Free speed test features for your own app

SpeedChecker Flutter plugin allows developers to integrate speed test features into their own flutter apps. You can also try our apps
on [Google Play](https://play.google.com/store/apps/details?id=uk.co.broadbandspeedchecker\&hl=en\_US)
and [App Store](https://itunes.apple.com/app/id658790195), they are powered by the latest Speedchecker SDK versions. More information
about [SpeedChecker SDKs](https://www.speedchecker.com/speed-test-tools/mobile-apps-and-sdks.html)

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

#### Android

* minSdkVersion 19
* Location permissions

By default, flutter projects have minSdkVersion set to 16. You need to change this to 19. You can find this setting in build.gradle file: Your_project_folder/android/app/build.gradle

```gradle
    defaultConfig {
    applicationId "com.example.test_project"
        minSdkVersion flutter.minSdkVersion  //REPLACE "flutter.minSdkVersion" to 19 
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
     }
````

#### iOS

* Xcode 13.3.1 or later
* Swift 5
* Development Target 11.0 or later

## Installation

#### 1. Run in the terminal:

```bash
$ flutter pub add speed_checker_plugin
``` 

This will add a line like this to your package's pubspec.yaml (and run an implicit flutter pub get):

```yaml
dependencies:
  speed_checker_plugin: ^1.0.15
```

#### 2. Import speed_checker_plugin in your Dart class.

```dart
import 'package:speed_checker_plugin/speed_checker_plugin.dart';
```

## Permission requirements

Free version of the plugin requires location permission to be able to perform a speed test. You need to handle location permission in your app level.
Check out our [location policy](https://github.com/speedchecker/flutter_plugin/wiki/Privacy-&-consent)

## Usage

#### 1. Create an instance of 'SpeedCheckerPlugin' class, StreamSubscription object to listen events from SpeedCheckerPlugin and all variables you need to store speed test results

```dart
final _plugin = SpeedCheckerPlugin();
late StreamSubscription<SpeedTestResult> _subscription;
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
```

#### 2. Start 'startSpeedTest' method in your class.
You can start this method on custom event, such as button click

```dart
_plugin.startSpeedTest();
```

Plugin supports starting speed test with custom server. You need to pass following server parameters to 'startSpeedTestWithCustomServer' method: domain, downloadFolderPath, uploadFolderPath, city, country, countryCode, id

```dart
_plugin.startSpeedTestWithCustomServer(
  domain: 'dig20ny.speedcheckerapi.com',
  downloadFolderPath: '/',
  uploadFolderPath: '/',
  city: 'New York 2',
  country: 'USA',
  countryCode: 'US',
  id: 104
);
```

#### 3. Listen to 'speedTestResultStream'. You can also handle errors and update UI accordingly. Don't forget to cancel subscription after stopping the test or on receiving error

```dart
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
    _ip = '';
    _isp = '';
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

});
```
#### 4. If you need to stop speed test, you can call plugin's 'stopTest' method. It will immediately interrupt speed test

```dart
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
````

#### 5. Plugin can return user IP address and Internet Service Provider (ISP) name. You can call plugin's 'getIpInfo' method to get this information. It will be returned as a Map<String, String> object after test is completed. Please, note that after stopping the test before completion, it will not return IP and ISP values.

```dart
  Future<void> getIpInfo() async {
    final ipInfo = await _plugin.getIpInfo();
    setState(() {
      _ip = ipInfo['ip']?.toString() ?? '';
      _isp = ipInfo['isp']?.toString() ?? '';
    });
  }
```

#### 6. Do not forget to close the stream to prevent memory leaks. It can be done by overriding 'dispose' method

```dart
@override
  void dispose() {
    _plugin.dispose();
    super.dispose();
}
````

## Demo application

Please check our [demo application](https://github.com/speedchecker/flutter_plugin) in Flutter which includes speed test functionality as well as
speedometer UI.

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
| Cost                              | **FREE**                      | Cost: [**Enquire**](https://www.speedchecker.com/contact-us.html)                       | Cost: [**Enquire**](https://www.speedchecker.com/contact-us.html) |

## FAQ

### **Is the SDK free to use?**

Yes! But the SDK collects data on network performance from your app and shares it with Speedchecker and our clients. The free SDK version requires and
enabled location. Those restrictions are not in the Basic and Advanced versions

### **Do you have also native SDKs?**

Yes, we have both [Android](https://github.com/speedchecker/speedchecker-sdk-android) and [iOS](https://github.com/speedchecker/speedchecker-sdk-ios)
SDKs.

### **Do you provide other types of tests?**

Yes! YouTube video streaming, Voice over IP and other tests are supported by our native SDK libraries. Check out our [Android](https://github.com/speedchecker/speedchecker-sdk-android/wiki/API-documentation) and [iOS](https://github.com/speedchecker/speedchecker-sdk-ios/wiki/API-documentation) API documentation

### **Do you provide free support?**

No, we provide support only on Basic and Advanced plans

### **What are all the metrics or KPIs that you can get using our native SDKs?**

The free version of our plugin allows getting basic metrics which are described in
this [API documentation](https://github.com/speedchecker/flutter_plugin/wiki/API-documentation)

[Full list of our KPIs for Basic and Advanced versions](https://docs.speedchecker.com/measurement-methodology-links/u21ongNGAYLb6eo7cqjY/kpis-and-measurements/list-of-kpis)

### **Do you host all infrastructure for the test?**

Yes, you do not need to run any servers. We provide and maintain a network of high-quality servers and CDNs to ensure the testing is accurate. If you
wish to configure your own server, this is possible on Basic and Advanced plans.

### **How do you measure the speed?**

See
our [measurement methodology](https://docs.speedchecker.com/measurement-methodology-links/u21ongNGAYLb6eo7cqjY/kpis-and-measurements/data-collection-methodologies)

## What's next?

Please contact us for more details and license requirements.

* [More information about SpeedChecker SDKs](https://www.speedchecker.com/speed-test-tools/mobile-apps-and-sdks.html)
* [API documentation](https://github.com/speedchecker/flutter_plugin/wiki/API-documentation)
* [Buy license](https://www.speedchecker.com/contact-us.html)
* [Contact us](https://www.speedchecker.com/contact-us.html)
