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

    func respond(request: Request, params: [String: String]) -> Response {
        var (request, response) = (request, Response())
        request.parameters = params
        response.request = request
        return action(request, response)
    }

    var friendlyString: String {
        return "\(method.rawValue) \(path)"
    }

    func validMatch(request: Request, data: [String: String]) -> Bool {
        return method == request.method
    }

    struct LinkView: HTMLView {
        let path: String
        let method: HTTPMethod

        var render: String {
            var pathString = path
            if method == .GET {
                pathString = Link(path, to: path).htmlString
            }
            return "\(method) \(pathString)"
        }
    }

    var htmlString: String {
        return LinkView(path: path, method: method).render
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

struct RouteView: HTMLView {
    let routes: [HTMLPrintableRoute]

    var render: String {
        let listElements = routes.map { Li($0.htmlString) as HTMLElement }

        return HTML5(head: [], body: [
            H2("Route not found, how about one of these?"),
            Ul(listElements)
        ]).render
    }
}

extension FlyRouter where Route: HTMLPrintableRoute {

    var HTMLRouteList: String {
        let printableRoutes = routes.map { $0 as HTMLPrintableRoute }
        return RouteView(routes: printableRoutes).render
    }
}

