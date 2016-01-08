typealias FlyAction = (FlyRequest, FlyResponse) -> FlyResponse
extension FlyRequest: Routable {}

struct HTTPRoute: RequestHandler, HTTPRoutable, HTMLPrintableRoute {
    typealias Request = FlyRequest
    typealias Response = FlyResponse

    let path: String
    let method: HTTPMethod
    let action: FlyAction

    static var defaultResponse: Response {
        return FlyResponse(status: .NotFound)
    }

    func handle(request: Request) -> Response {
        var response = Response()
        response.request = request
        return action(request, response)
    }

    var htmlString: String {
        var pathString = path
        if method == .GET {
            pathString = Link(path, path).htmlString
        }
        return Tag(.Li, "\(method) \(pathString)").htmlString
    }
}

protocol HTTPRoutable {
    init(path: String, method: HTTPMethod, action: FlyAction)
}

extension FlyRouter where Route: HTTPRoutable {
    mutating func route(path: String, method: HTTPMethod = .GET, action: FlyAction) {
        let route = Route(path: path, method: method, action: action)
        register(route)
    }

    mutating func GET(path: String, action: FlyAction) {
        self.route(path, method: .GET, action: action)
    }
}


protocol HTMLPrintableRoute {
    var htmlString: String { get }
}

extension FlyRouter where Route: HTMLPrintableRoute {
    var HTMLRouteList: String {
        // don't want to have to put [HTMLTag] here, would be nice to make that better
        let list: [String] = routes.map { route in
            route.htmlString
        }
        let template = HTML5([
            Tag(.H2, "Route not found, how about one of these?"),
            Tag(.Ul, list.joinWithSeparator("")),
        ])
        return template.htmlString
    }
}

