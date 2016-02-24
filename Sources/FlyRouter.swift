typealias FlyAction = (FlyRequest, FlyResponse) -> FlyResponse
extension FlyRequest: Routable {}

struct HTTPRoute: RequestHandler, HTTPRoutable {
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

    func validMatch(request: Request, data: [String: String]) -> Bool {
        return method == request.method
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

    mutating func get(path: String, action: FlyAction) {
        self.route(path, method: .GET, action: action)
    }
}


protocol HTMLPrintableRoute {
    var htmlString: String { get }
}

extension FlyRouter: HasHTML { }
extension FlyRouter where Route: HTMLPrintableRoute {

    var HTMLRouteList: String {
        return HTML5(head: [], body: [
            H2("Route not found, how about one of these?"),
            Ul(routes.map { Li($0.htmlString) })
        ]).render
    }
}

extension HTTPRoute: HTMLPrintableRoute {

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

