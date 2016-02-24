import Foundation

enum HTTPStatus: Int {
    // Informational
    case Continue = 100
    case SwitchingProtocols = 101
    case Processing = 102

    // Success
    case OK = 200
    case Created = 201
    case Accepted = 202
    case NonAuthoritativeInformation = 203
    case NoContent = 204
    case ResetContent = 205
    case PartialContent = 206
    case MultiStatus = 207
    case AlreadyReported = 208
    case IMUsed = 226

    // Redirections
    case MultipleChoices = 300
    case MovedPermanently = 301
    case Found = 302
    case SeeOther = 303
    case NotModified = 304
    case UseProxy = 305
    case SwitchProxy = 306
    case TemporaryRedirect = 307
    case PermanentRedirect = 308

    // Client Errors
    case BadRequest = 400
    case Unauthorized = 401
    case PaymentRequired = 402
    case Forbidden = 403
    case NotFound = 404
    case MethodNotAllowed = 405
    case NotAcceptable = 406
    case ProxyAuthenticationRequired = 407
    case RequestTimeout = 408
    case Conflict = 409
    case Gone = 410
    case LengthRequired = 411
    case PreconditionFailed = 412
    case RequestEntityTooLarge = 413
    case RequestURITooLong = 414
    case UnsupportedMediaType = 415
    case RequestedRangeNotSatisfiable = 416
    case ExpectationFailed = 417
    case ImATeapot = 418
    case AuthenticationTimeout = 419
    case UnprocessableEntity = 422
    case Locked = 423
    case FailedDependency = 424
    case UpgradeRequired = 426
    case PreconditionRequired = 428
    case TooManyRequests = 429
    case RequestHeaderFieldsTooLarge = 431
    case LoginTimeout = 440
    case NoResponse = 444
    case RetryWith = 449
    case UnavailableForLegalReasons = 451
    case RequestHeaderTooLarge = 494
    case CertError = 495
    case NoCert = 496
    case HTTPToHTTPS = 497
    case TokenExpired = 498
    case ClientClosedRequest = 499

    // Server Errors
    case InternalServerError = 500
    case NotImplemented = 501
    case BadGateway = 502
    case ServiceUnavailable = 503
    case GatewayTimeout = 504
    case HTTPVersionNotSupported = 505
    case VariantAlsoNegotiates = 506
    case InsufficientStorage = 507
    case LoopDetected = 508
    case BandwidthLimitExceeded = 509
    case NotExtended = 510
    case NetworkAuthenticationRequired = 511
    case NetworkTimeoutError = 599
}


// config values
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

extension Environment: Equatable {}

// looks like this will be automatic in a later version of Swift based on a proposal
func ==(lhs: Environment, rhs: Environment) -> Bool {
    return lhs.string == rhs.string
}

let env = Environment.custom("staging")

env == Environment.Production
env == Environment.Development
env == Environment.custom("staging")


// FlyConfig
protocol FlyConfig {
    var environment: Environment { get }
    var showDebugRoutes: Bool { get }
}

extension FlyConfig {
    var environment: Environment { return Environment.Production }
    var showDebugRoutes: Bool { return environment != Environment.Production }
}

// FlyApp
protocol FlyApp: class {
    var config: FlyConfig { get set }
    var router: FlyRouter { get }
    init(config: FlyConfig)
}

class App: FlyApp {
    var config: FlyConfig
    var router = FlyRouter()

    required init(config: FlyConfig) {
        self.config = config
    }

    var environment: Environment {
        return config.environment
    }
}

enum HTTPMethod: String {
    case GET, PUT, POST, DELETE
    // Patch?
}

struct FlyRequest {
    let path: String
    let method: HTTPMethod

    init(path: String, method: HTTPMethod = .GET) {
        self.path = path
        self.method = method
    }
}

struct FlyResponse {
    var request: FlyRequest = FlyRequest(path: "")
    var status: HTTPStatus = .OK
    var body: String = ""

    init() { }
    init(status: HTTPStatus) {
        self.status = status
    }
    init(body: String) {
        self.body = body
    }

    var tuple: (status: HTTPStatus, body: String) {
        return (status, body)
    }
}

extension FlyResponse: StringLiteralConvertible {
    typealias UnicodeScalarLiteralType = StringLiteralType
    init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(stringLiteral: value)
    }

    typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(stringLiteral: value)
    }

    init(stringLiteral value: StringLiteralType) {
        self.init(body: value)
    }
}

typealias FlyAction = (FlyRequest, FlyResponse) -> FlyResponse

// would be cool to be able to nest routers
// maybe even have a pattern where a controller defines a router, and then nests it at a mount point?
// that would make refactoring routes really easy
// not sure if it's better to generate flat routes as they are added somehow,
// or to have a nested scheme where the nesting is calculated at matching time...
struct FlyRouter {

    var routes = [Routable]()

    mutating func register(routes: Routable...) {
        register(routes)
    }
    mutating func register(routes: [Routable]...) {
        self.routes.appendContentsOf(routes.flatMap{$0})
    }

    func handle(request: FlyRequest) -> FlyResponse {
        guard let route = matchingRoute(request) else { return FlyResponse(status: .NotFound) }
        var response = FlyResponse()
        response.request = request
        return route.action(request, response)
    }

    // if path matches but not method, could suggest that to warn the dev about the potential problem
    func matchingRoute(request: FlyRequest) -> Routable? {
        for route in routes {
            if route.matches(request) {
                return route
            }
        }
        return nil
    }

    var friendlyRouteList: String {
        let list = routes.map { return "\($0.method) \($0.path)" }
        return list.joinWithSeparator("\n")
    }
}

extension FlyRouter {
    struct Route: Routable {
        let path: String
        let method: HTTPMethod
        let action: FlyAction
    }

    mutating func route(path: String, method: HTTPMethod = .GET, action: FlyAction) {
        let route = Route(path: path, method: method, action: action)
        register(route)
    }

    mutating func get(path: String, action: FlyAction) {
        self.route(path, method: .GET, action: action)
    }
}

protocol Routable {
    var path: String { get }
    var action: FlyAction { get }

    // default implementation returns .GET
    var method: HTTPMethod { get }
}

extension Routable {
    var method: HTTPMethod { return .GET }
    //    var actions: [Routable.Type] { return [] }

    func matchesPath(path: String) -> Bool {
        return self.path == path
    }

    func matches(request: FlyRequest) -> Bool {
        return method == request.method && matchesPath(request.path)
    }
}


enum Route {
    case showUser(Int)
    case editUser(Int)

    static var cases: [Any] {
        return [showUser, editUser]
    }

    static var caseTemplates: [Route] {
        return cases.flatMap { route in
            switch route {
            case let route as Route:
                return route
            case let route as (Int) -> Route:
                return route(123)
            default:
                return nil
            }
        }
    }

    var url: String {
        switch self {
        case .showUser:
            return "/users/:id/show"
        case .editUser:
            return "/users/:id/edit"
        }
    }
}

let templates = Route.caseTemplates.map { $0.url }
templates

let show = Route.showUser(24)
show.url


struct BaseRoute: Routable {
//    var method = HTTPMethod.GET
    var path: String
    var action: FlyAction

    init(_ path: String, action: FlyAction) {
        self.path = path
        self.action = action
    }
}


extension RoutableController {
    func matchesPath(path: String) -> Bool {
        return self.dynamicType.path.containsString(path)
    }
}

protocol RoutableController {
    static var path: String { get }
    static var routes: [Routable] { get }
}


class SomeController: RoutableController {
    static var path = "posts"
    static var routes: [Routable] = [
        BaseRoute("whatever") { request, response in
            return "yes, whatever"
        },
        BaseRoute("thingy/:id/okay") { request, response in
            return "thingy thing thing"
        }
    ]
    var routeTypes = [Routable.Type]()
}

//let mirror = Mirror(reflecting: SomeController.self)
//mirror.children


struct Config: FlyConfig {
    var environment = Environment.Development
}

class UserController {
    class func createUser(request: FlyRequest, response: FlyResponse) -> FlyResponse {
        var response = response
        response.body = "Creating a new user!"
        return response
    }
}

let app = App(config: Config())

let route = FlyRouter.Route(path: "/test", method: .GET) { request, response in
    return "Tested."
}

app.router.register(route, route, route)


app.router.route("/") { request, response in
    var response = response
    response.request
    response.body = "Home page!"
    return response
}

// not sure I like the .GET/.POST stuff:
app.router.GET("/welcome") { request, response in
    return "Welcome to our web page"
}

app.router.route("/welcome", method: .POST) { request, response in
    return "Why are you posting to /welcome?"
}

app.router.route("/users/:id/create", method: .POST, action: UserController.createUser)

app.router.handle(FlyRequest(path: "/")).tuple
app.router.handle(FlyRequest(path: "/", method: .POST)).tuple
app.router.handle(FlyRequest(path: "/welcome")).tuple
app.router.handle(FlyRequest(path: "/welcome", method: .POST)).tuple
app.router.handle(FlyRequest(path: "/users/new", method: .POST)).tuple

print(app.router.friendlyRouteList)

