
protocol FlyApp: class {
    var config: FlyConfig { get set }
    var router: FlyRouter { get }
    init(config: FlyConfig)
}

extension FlyApp {
  func setup() { }
}

class App: FlyApp {
    var config: FlyConfig
    var router: FlyRouter

    required init(config: FlyConfig) {
        self.config = config
        self.router = FlyRouter(debug: config.showDebugRoutes)
        setup()
    }

    var environment: Environment {
        return config.environment
    }

}

