import Cocoa


// https://github.com/rhodgkins/SwiftHTTPStatusCodes/blob/master/HTTPStatusCodes.swift#L44
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

// looks like this will be automatic in a later version of Swift
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
}

extension FlyConfig {
    var environment: Environment { return .Production }
}

// FlyApp
//protocol FlyApp: class {
//    var config: FlyConfig { get set }
//
//    init(config: FlyConfig)
//}

class FlyApp {
    var config: FlyConfig
    var router = FlyRouter()

    init(config: FlyConfig) {
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
struct FlyRouter {
    var routes = [FlyRoute]()

    mutating func GET(path: String, action: FlyAction) {
        self.route(path, method: .GET, action: action)
    }

    mutating func route(path: String, method: HTTPMethod = .GET, action: FlyAction) {
        let route = FlyRoute(path: path, method: method, action: action)
        routes.append(route)
    }

    func handle(request: FlyRequest) -> FlyResponse {
        guard let route = matchingRoute(request) else { return FlyResponse(status: .NotFound) }
        var response = FlyResponse()
        response.request = request
        return route.action(request, response)
    }

    // if path matches but not method, could suggest that to warn the dev about the potential problem
    func matchingRoute(request: FlyRequest) -> FlyRoute? {
        return routes.filter { route in
            request.method == route.method &&
            request.path == route.path
        }.first
    }

    var friendlyRouteList: String {
        let list = routes.map { return "\($0.method) \($0.path)" }
        return list.joinWithSeparator("\n")
    }
}

struct FlyRoute {
    let path: String
    let method: HTTPMethod
    let action: FlyAction
}

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

//class App: FlyApp {
//
//}

let app = FlyApp(config: Config())

app.environment

app.router.route("/") { request, response in
    var response = response
    response.request
    response.body = "Home page!"
    return response
}

// not sure I like this:
app.router.GET("/welcome") { request, response in
    return "Welcome to our web page"
}

//app.router.route("/welcome", method: .GET) { request in
//    var response = FlyResponse(status: .OK)
//    response.body = "Welcome to our web page"
//    return response
//}

app.router.route("/welcome", method: .POST) { request, response in
    return "Why are you posting to /welcome?"
}

app.router.route("/users/new", method: .POST, action: UserController.createUser)


app.router.handle(FlyRequest(path: "/")).tuple
app.router.handle(FlyRequest(path: "/", method: .POST)).tuple
app.router.handle(FlyRequest(path: "/welcome")).tuple
app.router.handle(FlyRequest(path: "/welcome", method: .POST)).tuple
app.router.handle(FlyRequest(path: "/suck")).tuple
app.router.handle(FlyRequest(path: "/users/new", method: .POST)).tuple


print(app.router.friendlyRouteList)


