
public protocol FlyApp: class {
    public var config: FlyConfig { get set }
    public var router: Router<HTTPRoute> { get }
    public init(config: FlyConfig)

    // have default implementations, but can be overridden
    public func logRequest(request: FlyRequest, response: FlyResponse)
    public static var logDirectory: String { get }
}

public extension FlyApp {
    public func setup() { }
    public func logRequest(request: FlyRequest, response: FlyResponse) {
        App.log("\(request.method) \(request.path) -> \(response.status.description)")
    }

    public static var logDirectory: String { return "log" }
}

public protocol FlyServer {
    static func start(app: FlyApp, port: Int)
}


