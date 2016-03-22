import Foundation

protocol FlyApp: class {
    var config: FlyConfig { get set }
    var router: FlyRouter<HTTPRoute> { get }
    init(config: FlyConfig)

    // overrideable, but with default values
    func logRequest(request: FlyRequest, response: FlyResponse)
    static var logDirectory: String { get }
}

extension FlyApp {
    func setup() { }
    func logRequest(request: FlyRequest, response: FlyResponse) {
        App.log("\(request.method) \(request.path) -> \(response.status.description)")
    }

    static var logDirectory: String { return "log" }
}

class App: FlyApp {
    var config: FlyConfig
    var router: FlyRouter<HTTPRoute>

    required init(config: FlyConfig) {
        self.config = config
        self.router = FlyRouter()
        setup()
    }

    var environment: Environment {
        return config.environment
    }

    // static let standardOutput = NSFileHandle.fileHandleWithStandardOutput()
    // static var outputStream: NSOutputStream {
    //     let stream = NSOutputStream(toFileAtPath: filePath, append: true) ?? NSOutputStream.outputStreamToMemory()
    //     stream.open()
    //     return
    // }

    static func log(values: Any...) {
        let string = values.map { "\($0)" }.joined(separator: " ")
        print(string)
        logToFile(string)
    }

    static func logToFile(string: String) {
        #if os(OSX)
            // let filePath = "logs/\(environment.string).log"
            let filePath = "\(logDirectory)/development.log"
            do {
                try NSFileManager.defaultManager().createDirectory(atPath: logDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print("could not create log directory", error);
            }

            if let outputStream = NSOutputStream(toFileAtPath: filePath, append: true) {
                outputStream.open()
                outputStream.write(string + "\n")
                outputStream.close()
            } else {
                print("Unable to open log file")
            }
        #elseif os(Linux)
            // TODO
        #endif

    }
}

protocol FlyServer {
    static func start(app: FlyApp, port: Int)
}


#if os(OSX)
// http://stackoverflow.com/questions/26989493/how-to-open-file-and-append-a-string-in-it-swift
extension NSOutputStream {

    /// Write String to outputStream
    ///
    /// - parameter string:                The string to write.
    /// - parameter encoding:              The NSStringEncoding to use when writing the string. This will default to UTF8.
    /// - parameter allowLossyConversion:  Whether to permit lossy conversion when writing the string.
    ///
    /// - returns:                         Return total number of bytes written upon success. Return -1 upon failure.
    func write(string: String, encoding: NSStringEncoding = NSUTF8StringEncoding, allowLossyConversion: Bool = true) -> Int {
        if let data = string.data(usingEncoding: encoding, allowLossyConversion: allowLossyConversion) {
            var bytes = UnsafePointer<UInt8>(data.bytes)
            var bytesRemaining = data.length
            var totalBytesWritten = 0

            while bytesRemaining > 0 {
                let bytesWritten = self.write(bytes, maxLength: bytesRemaining)
                if bytesWritten < 0 {
                    return -1
                }

                bytesRemaining -= bytesWritten
                bytes += bytesWritten
                totalBytesWritten += bytesWritten
            }

            return totalBytesWritten
        }

        return -1
    }

}
#endif

