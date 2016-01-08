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
    func handle(request: Request) -> Response

    // have default implementations, but can be overrided
    var friendlyString: String { get }
    func matches(request: Request) -> Bool
}

extension RequestHandler {

    var friendlyString: String {
        return path
    }

    func matches(request: Request) -> Bool {
        return matchesPath(request.path)
    }

    func matchesPath(path: String) -> Bool {
        // TODO regex stuff
        return self.path == path
    }
}

