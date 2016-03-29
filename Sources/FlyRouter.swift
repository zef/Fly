import AirTrafficController
import SwifTML
import HTTPStatus

typealias FlyAction = (FlyRequest, FlyResponse) -> FlyResponse
extension FlyRequest: Routable {}

public struct HTTPRoute: RequestHandler, HTTPRoutable {
    typealias Request = FlyRequest
    typealias Response = FlyResponse

    public let path: String
    public let method: HTTPMethod
    public let action: FlyAction

    public static var defaultResponse: Response {
        return FlyResponse(status: HTTPStatus.NotFound)
    }

    public func respond(request: Request, params: [String: String]) -> Response {
        var (request, response) = (request, Response())
        request.parameters = params
        response.request = request
        return action(request, response)
    }

    public func validMatch(request: Request, data: [String: String]) -> Bool {
        return method == request.method
    }

    public var description: String {
        return "\(method) \(path)"
    }
}

public protocol HTTPRoutable {
    public init(path: String, method: HTTPMethod, action: FlyAction)
}

public extension Router where Route: HTTPRoutable {
    public mutating func route(path: String, method: HTTPMethod = .GET, action: FlyAction) {
        let route = Route(path: path, method: method, action: action)
        register(route)
    }

    public mutating func get(path: String, action: FlyAction) {
        self.route(path, method: .GET, action: action)
    }
}


public protocol HTMLPrintableRoute {
    public var htmlString: String { get }
}

public extension Router: SwifTML { }
public extension Router where Route: HTMLPrintableRoute {

    public var HTMLRouteList: String {
        return HTML5(head: [], body: [
            H2("Route not found, how about one of these?"),
            Ul(routes.map { Li($0.htmlString) })
        ]).render
    }
}

public extension HTTPRoute: HTMLPrintableRoute {

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

    public var htmlString: String {
        return LinkView(path: path, method: method).render
    }
}

