import Foundation

protocol FlyApp: class {
    var config: FlyConfig { get set }
    var router: FlyRouter<HTTPRoute> { get }
    init(config: FlyConfig)
}

extension FlyApp {
  func setup() { }
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

    static let standardOutput = NSFileHandle.fileHandleWithStandardOutput()
    static func log(values: Any...) {
        let string = values.map { "\($0)" }.joinWithSeparator(" ")
        if let data = "\n\(string)".dataUsingEncoding(NSUTF8StringEncoding) {
            standardOutput.writeData(data)
        }
    }
}

protocol FlyServer {
    static func start(app: FlyApp, port: Int)
}

