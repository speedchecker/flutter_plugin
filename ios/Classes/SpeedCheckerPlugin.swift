import Flutter
import UIKit
import CoreLocation
import SpeedcheckerSDK

public class SpeedCheckerPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    
    private var locationManager = CLLocationManager()
    private var internetSpeedTest: InternetSpeedTest?
    
    private var resultDict = [String: Any]()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "speed_checker_plugin", binaryMessenger: registrar.messenger())
        let instance = SpeedCheckerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        instance.requestLocation()
        instance.setupEventChannel(messanger: registrar.messenger())
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
    }
    
    // MARK: - Helpers
    
    fileprivate func requestLocation() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.requestAlwaysAuthorization()
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    fileprivate func setupEventChannel(messanger: FlutterBinaryMessenger) {
        let speedcheckerChannel = FlutterEventChannel(name: "speedChecker_eventChannel",
                                                      binaryMessenger: messanger)
        speedcheckerChannel.setStreamHandler(self)
    }
    
    private func sendErrorResult(_ error: SpeedTestError) {
        print(error.localizedDescription)
        eventSink?(["error": error.localizedDescription])
    }
    
    private func sendResultDict() {
        eventSink?(resultDict)
    }
    
    // MARK: - FlutterStreamHandler
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        
        internetSpeedTest = InternetSpeedTest(delegate: self)
        internetSpeedTest?.startTest() { (error) in
            if error != .ok {
                sendErrorResult(error)
            } else {
                resultDict = [
                    "status": "Speed test started",
                    "server": "",
                    "ping": 0,
                    "downloadSpeed": 0,
                    "percent": 0,
                    "currentSpeed": 0,
                    "uploadSpeed": 0,
                    "connectionType": ""
                ]
                eventSink?(resultDict)
            }
        }
        
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}

extension SpeedCheckerPlugin: InternetSpeedTestDelegate {
    public func internetTestError(error: SpeedTestError) {
        sendErrorResult(error)
    }
    
    public func internetTestFinish(result: SpeedTestResult) {
        print(result.downloadSpeed.mbps)
        print(result.uploadSpeed.mbps)
        print(result.latencyInMs)
        resultDict["status"] = "Speed test finished"
        resultDict["server"] = result.server.domain
        resultDict["ping"] = result.latencyInMs
        resultDict["downloadSpeed"] = result.downloadSpeed.mbps
        resultDict["uploadSpeed"] = result.uploadSpeed.mbps
        resultDict["connectionType"] = result.connectionType
        sendResultDict()
    }
    
    public func internetTestReceived(servers: [SpeedTestServer]) {
        resultDict["status"] = "Ping"
        sendResultDict()
    }
    
    public func internetTestSelected(server: SpeedTestServer, latency: Int, jitter: Int) {
        print("Latency: \(latency)")
        print("Jitter: \(jitter)")
        resultDict["ping"] = latency
        resultDict["server"] = server.domain
        sendResultDict()
    }
    
    public func internetTestDownloadStart() {
        resultDict["status"] = "Download"
        sendResultDict()
    }
    
    public func internetTestDownloadFinish() {
        
    }
    
    public func internetTestDownload(progress: Double, speed: SpeedTestSpeed) {
        print("Download: \(speed.descriptionInMbps)")
        resultDict["percent"] = Int(progress * 100)
        resultDict["currentSpeed"] = speed.mbps
        resultDict["downloadSpeed"] = speed.mbps
        sendResultDict()
    }
    
    public func internetTestUploadStart() {
        resultDict["status"] = "Upload"
        resultDict["currentSpeed"] = 0
        resultDict["percent"] = 0
        sendResultDict()
    }
    
    public func internetTestUploadFinish() {
    }
    
    public func internetTestUpload(progress: Double, speed: SpeedTestSpeed) {
        print("Upload: \(speed.descriptionInMbps)")
        resultDict["percent"] = Int(progress * 100)
        resultDict["currentSpeed"] = speed.mbps
        resultDict["uploadSpeed"] = speed.mbps
        sendResultDict()
    }
}

extension SpeedCheckerPlugin: CLLocationManagerDelegate {
}

extension SpeedTestError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .ok:
            return "Ok"
        case .invalidSettings:
            return "Invalid settings"
        case .invalidServers:
            return "Invalid servers"
        case .inProgress:
            return "In progress"
        case .failed:
            return "Failed"
        case .notSaved:
            return "Not saved"
        case .cancelled:
            return "Cancelled"
        case .locationUndefined:
            return "Location undefined"
        @unknown default:
            return "Unknown"
        }
    }
}

