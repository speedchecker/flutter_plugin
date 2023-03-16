import Flutter
import UIKit
import CoreLocation
import SpeedcheckerSDK

public class SpeedCheckerPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    
    private var locationManager = CLLocationManager()
    private var internetSpeedTest: InternetSpeedTest?
    
    private var server: SpeedTestServer?
    
    private var resultDict = [String: Any]()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "speedChecker_methodChannel", binaryMessenger: registrar.messenger())
        let instance = SpeedCheckerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        instance.requestLocation()
        instance.setupEventChannel(messanger: registrar.messenger())
    }
    
    // MARK: - Handle Flutter method calls
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let method = Method(rawValue: call.method) else {
            result(FlutterMethodNotImplemented)
            return
        }
        
        switch method {
        case .customServer:
            handleCustomServerMethod(call.arguments, result: result)
        }
    }
    
    private func handleCustomServerMethod(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let dict = arguments as? [String: Any] else {
            result(FlutterError(code: "BAD_ARGS", message: "Wrong argument types", details: nil))
            return
        }
        
        let server = SpeedTestServer(
            ID: dict["id"] as? Int,
            scheme: "https",
            domain: dict["domain"] as? String,
            downloadFolderPath: (dict["downloadFolderPath"] as? String)?.replacingOccurrences(of: "\\", with: ""),
            uploadFolderPath: (dict["uploadFolderPath"] as? String)?.replacingOccurrences(of: "\\", with: ""),
            uploadScript: "php",
            countryCode: dict["countryCode"] as? String,
            cityName: dict["city"] as? String
        )
        
        self.server = server
        result("Custom server set")
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
    
    private func resetServer() {
        server = nil
    }
    
    private func startTest() {
        internetSpeedTest = InternetSpeedTest(delegate: self)
        
        let onTestStart: (SpeedcheckerSDK.SpeedTestError) -> Void = { (error) in
            if error != .ok {
                self.sendErrorResult(error)
                self.resetServer()
            } else {
                self.resultDict = [
                    "status": "Speed test started",
                    "server": "",
                    "ping": 0,
                    "jitter": 0,
                    "downloadSpeed": 0,
                    "percent": 0,
                    "currentSpeed": 0,
                    "uploadSpeed": 0,
                    "connectionType": "",
                    "serverInfo": "",
                    "deviceInfo": "",
                    "downloadTransferredMb": 0,
                    "uploadTransferredMb": 0
                ]
                self.eventSink?(self.resultDict)
            }
        }
        
        if let server = server, !(server.domain ?? "").isEmpty {
            internetSpeedTest?.start([server], completion: onTestStart)
        } else {
            internetSpeedTest?.startTest(onTestStart)
        }
    }
    
    private func checkPermissionsAndStartTest() {
        SCLocationHelper().locationServicesEnabled { locationEnabled in
            guard locationEnabled else {
                self.sendErrorResult(.locationUndefined)
                return
            }
            
            self.startTest()
        }
    }
    
    // MARK: - FlutterStreamHandler
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        
        checkPermissionsAndStartTest()
        
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
        resetServer()
    }
    
    public func internetTestFinish(result: SpeedTestResult) {
        print(result.downloadSpeed.mbps)
        print(result.uploadSpeed.mbps)
        print(result.latencyInMs)
        resultDict["status"] = "Speed test finished"
        resultDict["server"] = result.server.domain
        resultDict["ping"] = result.latencyInMs
        resultDict["jitter"] = result.jitter
        resultDict["downloadSpeed"] = result.downloadSpeed.mbps
        resultDict["uploadSpeed"] = result.uploadSpeed.mbps
        resultDict["connectionType"] = result.connectionType
        resultDict["serverInfo"] = [result.server.cityName, result.server.country].compactMap({ $0 }).joined(separator: ", ")
        resultDict["deviceInfo"] = result.deviceInfo
        resultDict["downloadTransferredMb"] = result.downloadTransferredMb
        resultDict["uploadTransferredMb"] = result.uploadTransferredMb
        sendResultDict()
        resetServer()
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
        resultDict["jitter"] = jitter
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

private extension SpeedCheckerPlugin {
    enum Method: String {
        case customServer
    }
}

