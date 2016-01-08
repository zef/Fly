//: Playground - noun: a place where people can play

import UIKit

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


enum HTTPMethod: String {
    case GET, PUT, POST, DELETE
    // Patch?
}

struct FlyRequest {
    let path: String
    let method: HTTPMethod

    init(_ path: String, method: HTTPMethod = .GET) {
        self.path = path
        self.method = method
    }
}

struct FlyResponse {
    var request: FlyRequest = FlyRequest("")
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
// not sure if it's better to generate flat routes as they are added,
// or to have a nested scheme where the nesting is calculated at matching time...
// kinda prefer the latter
struct FlyRouter<Route: RequestHandler> {

    var routes = [Route]()

    mutating func register(routes: Route...) {
        register(routes)
    }
    mutating func register(routes: [Route]...) {
        self.routes.appendContentsOf(routes.flatMap{$0})
    }

    func handle(request: Route.Request) -> Route.Response {
        guard let matchData = routeMatchData(request) else { return Route.defaultResponse }
        return matchData.route.respond(request, params: matchData.data)
    }

    // if path matches but not method, could suggest that to warn the dev about the potential problem
    func routeMatchData(request: Route.Request) -> (route: Route, data: [String: String])? {
        for route in routes {
            if let data = route.dataFromPath(request.path) where route.validMatch(request, data: data) {
                return (route, data)
            }
        }
        return nil
    }

    var friendlyRouteList: String {
        return routes.map { return $0.friendlyString }.joinWithSeparator("\n")
    }
}

protocol Routable {
    var path: String { get }
}

protocol RequestHandler {
    typealias Request: Routable
    typealias Response

    // returned response when no routes match
    static var defaultResponse: Response { get }

    var path: String { get }
    func respond(request: Request, params: [String: String]) -> Response

    // have default implementations, but can be overrided
    var friendlyString: String { get }
    func validMatch(request: Request, data: [String: String]) -> Bool
}


extension RequestHandler {

    var friendlyString: String {
        return self.path
    }

    func validMatch(request: Request, data: [String: String]) -> Bool {
        return true
    }

    func dataFromPath(requestPath: String) -> [String: String]? {
        let templateComponents = path.characters.split(" ").map{ String($0) }
        let pathComponents = requestPath.characters.split(" ").map{ String($0) }

        guard templateComponents.count == pathComponents.count else { return nil }

        let valueIdentifiers = templateComponents.reduce([String]()) { result, component in
            var result = result
            if component.characters.first == ":" {
                result.append(component)
            }
            return result
        }
        let valueIndices = valueIdentifiers.flatMap { templateComponents.indexOf($0) }

        var data = [String: String]()
        for (index, component) in templateComponents.enumerate() {
            guard index < pathComponents.endIndex else { return nil }

            if let valueIndex = valueIndices.indexOf(index) {
                let key = String(valueIdentifiers[valueIndex].characters.dropFirst())
                data[key] = pathComponents[index]
            } else {
                if component != pathComponents[index] {
                    return nil
                }
            }
        }

        return data
    }
}

extension String: Routable {
    var path: String {
        return self
    }
}

struct Route: RequestHandler {
    typealias Request = String
    typealias Response = Bool

    let path: String
    let action: (params: [String: String]) -> Response

    static var defaultResponse: Response {
        return false
    }

    func respond(request: Request, params: [String: String]) -> Response {
        return action(params: params)
    }

}

var stringRouter = FlyRouter<Route>()

stringRouter.register(
    Route(path: "whatever", action: { params in
        print("whatever params", params)
        return true
    }),
    Route(path: "something/:id/create", action: { params in
        print("something params", params)
        return true
    })
)

stringRouter.handle("nothing")
stringRouter.handle("something/2/create")
stringRouter.handle("something/22/create")
stringRouter.handle("hello there")
stringRouter.handle("whatever")

stringRouter.friendlyRouteList


extension FlyRequest: Routable {}