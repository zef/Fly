public enum Environment {
    case Production, Development, custom(String)

    public var string: String {
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

extension Environment: Equatable {}

// looks like this will be automatic in a later version of Swift
public func ==(lhs: Environment, rhs: Environment) -> Bool {
    return lhs.string == rhs.string
}


// FlyConfig
public protocol FlyConfig {
    var environment: Environment { get }
    var showDebugRoutes: Bool { get }
}

extension FlyConfig {
    var environment: Environment { return .Production }
    var showDebugRoutes: Bool { return environment == Environment.Development }
}

