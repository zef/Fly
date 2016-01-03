enum Environment {
    case Production, Development, custom(String)

    var string: String {
        switch self  {
        case .Production:
            return "Production"
        case .Development:
            return "Development"
        case .custom(let string):
            return string
        }
    }
}

// looks like this will be automatic in a later version of Swift
func ==(lhs: Environment, rhs: Environment) -> Bool {
    return lhs.string == rhs.string
}


// FlyConfig
protocol FlyConfig {
    var environment: Environment { get }
    var showDebugRoutes: Bool { get }
}

extension FlyConfig {
    var environment: Environment { return .Production }
    var showDebugRoutes: Bool { return environment == Environment.Development }
}

