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
    var debug = false

    init(debug: Bool) {
        self.debug = debug
    }

    mutating func register(routes: Route...) {
        register(routes)
    }
    mutating func register(routes: [Route]...) {
        self.routes.appendContentsOf(routes.flatMap{$0})
    }

    func handle(request: Route.Request) -> Route.Response {
        guard let route = matchingRoute(request) else { return Route.defaultResponse }
        return route.handle(request)
    }

    // if path matches but not method, could suggest that to warn the dev about the potential problem
    func matchingRoute(request: Route.Request) -> Route? {
        for route in routes {
            if route.matches(request) {
                return route
            }
        }
        if debug {
//            return debugRoute
            return nil
        } else {
            return nil
        }
    }

    var friendlyRouteList: String {
        return routes.map { return $0.friendlyString }.joinWithSeparator("\n")
    }

//    var debugRoute: Route {
//        return Route(path: "/routes", method: .GET, action: debugAction)
//    }
//
//    var debugAction: FlyAction {
//        return { request, response in
//            var response = FlyResponse(status: .NotFound)
//            response.body = self.HTMLRouteList
//            return response
//        }
//    }
}

//protocol Routable {
//    var path: String { get }
//    var action: FlyAction { get }
//
////    // default implementation returns .GET
////    var method: HTTPMethod { get }
//}

//struct ArgumentParser {
//    let path = "some/path/:id/and/:whatever"
//    let id: Int
//    let whatever: String
//
//    init(path: String) {
////        self.id = 
//
//    }
//}

protocol Routable {
    var path: String { get }
}

protocol RequestHandler {
    typealias Request: Routable
    typealias Response

    static var defaultResponse: Response { get }
    var path: String { get }
    func handle(request: Request) -> Response
}

extension RequestHandler {

    var friendlyString: String {
        return self.path
    }

    func matches(request: Request) -> Bool {
        return matchesPath(request.path)
    }

    func matchesPath(path: String) -> Bool {
        // TODO regex stuff
        return self.path == path
    }
}

//FlyResponse(status: .NotFound)


extension String: Routable {
    var path: String {
        return self
    }
}

struct StringRoute: RequestHandler {
    typealias Request = String
    typealias Response = Bool

    let path: String
    let action: () -> Response

    static var defaultResponse: Response {
        return false
    }

    func handle(request: Request) -> Response {
        return action()
    }

}

var stringRouter = FlyRouter<StringRoute>(debug: false)

stringRouter.register(
    StringRoute(path: "whatever", action: {
        print("whatever route")
        return true
    })
)

stringRouter.handle("nothing")
stringRouter.handle("hello there")
stringRouter.handle("whatever")

stringRouter.friendlyRouteList


extension FlyRequest: Routable {}

protocol HTMLPrintableRoute {
    var htmlString: String { get }
}

struct HTTPRoute: RequestHandler, HTMLPrintableRoute {
    typealias Request = FlyRequest
    typealias Response = FlyResponse

    let path: String
    let method: HTTPMethod
    let action: (Request, Response) -> Response

    static var defaultResponse: Response {
        return FlyResponse(status: .NotFound)
    }

    func handle(request: Request) -> Response {
        var response = Response()
        response.request = request
        return action(request, response)
    }

    var htmlString: String {
        return "link \(path)"
    }
}

var flyRouter = FlyRouter<HTTPRoute>(debug: false)

let httpRoute = HTTPRoute(path: "hey", method: .POST) { request, response in
    return "matched hey"
}

flyRouter.register(httpRoute)
flyRouter.routes.first?.htmlString

extension FlyRouter where Route: HTMLPrintableRoute {
    var HTMLRouteList: String {
        return "HTML"
    }
//        // don't want to have to put [HTMLTag] here, would be nice to make that better
//        let list: [HTMLTag] = routes.map { route in
//            var path = route.path
//            if route.method == .GET {
//                path = Link(route.path, route.path).htmlString
//            }
//            return Tag(.Li, "\(route.method) \(path)")
//        }
//        let template = HTML5([
//            Tag(.H2, "Route not found, how about one of these?"),
//            Tag(.Ul, htmlTags: list),
//            ])
//        return template.htmlString
//    }
}

extension FlyRouter {
//    struct Route: Routable {
//        let path: String
//        let method: HTTPMethod
//        let action: FlyAction
//    }
//
//    mutating func route(path: String, method: HTTPMethod = .GET, action: FlyAction) {
//        let route = Route(path: path, method: method, action: action)
//        register(route)
//    }
//
//    mutating func GET(path: String, action: FlyAction) {
//        self.route(path, method: .GET, action: action)
//    }
}
