typealias FlyAction = (FlyRequest, FlyResponse) -> FlyResponse

struct FlyRoute {
    let path: String
    let method: HTTPMethod
    let action: FlyAction
}

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

