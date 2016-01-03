typealias FlyAction = (FlyRequest, FlyResponse) -> FlyResponse

// would be cool to be able to nest routers
// maybe even have a pattern where a controller defines a router, and then nests it at a mount point?
// that would make refactoring routes really easy
// not sure if it's better to generate flat routes as they are added somehow,
// or to have a nested scheme where the nesting is calculated at matching time...
struct FlyRouter {

    var routes = [Routable]()
    var debug = false

    init(debug: Bool) {
        self.debug = debug
    }

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
        if debug {
            return debugRoute
        } else {
            return nil
        }
    }

    var debugRoute: Route {
        return Route(path: "/routes", method: .GET, action: debugAction)
    }

    var debugAction: FlyAction {
        return { request, response in
            let body = "Route not found, how about one of these?\n\n\(self.friendlyRouteList)"
            return FlyResponse(body: body)
        }
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

    mutating func GET(path: String, action: FlyAction) {
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

