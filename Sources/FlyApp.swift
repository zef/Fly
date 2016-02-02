
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
}

protocol FlyServer {
    static func start(app: FlyApp, port: Int)
}

