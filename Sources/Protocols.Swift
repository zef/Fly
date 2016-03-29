
public protocol FlyApp: class {
    var config: FlyConfig { get set }
    var router: Router<HTTPRoute> { get }
    init(config: FlyConfig)

    // have default implementations, but can be overridden
    func logRequest(request: FlyRequest, response: FlyResponse)
    static var logDirectory: String { get }
}

public extension FlyApp {
    func setup() { }
    func logRequest(request: FlyRequest, response: FlyResponse) {
        App.log("\(request.method) \(request.path) -> \(response.status.description)")
    }

    static var logDirectory: String { return "log" }
}

public protocol FlyServer {
    static func start(app: FlyApp, port: Int)
}


