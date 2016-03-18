import UIKit

// would be cool to be able to nest routers
// maybe even have a pattern where a controller defines a router, and then nests it at a mount point?
// that would make refactoring routes really easy
// not sure if it's better to generate flat routes as they are added,
// or to have a nested scheme where the nesting is calculated at matching time...
// kinda prefer the latter
struct Router<Route: RequestHandler> {

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
        let templateComponents = path.characters.split("/").map{ String($0) }
        let pathComponents = requestPath.characters.split("/").map{ String($0) }

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

// end of generic router, now showing an example of how to use it with a simple Route class that takes a String and returns a Bool

extension String: Routable {
    var path: String {
        return self
    }
}

struct Route: RequestHandler {
    typealias Request = String
    typealias Response = Bool

    let path: String
    let action: (request: Request, params: [String: String]) -> Response

    static var defaultResponse: Response {
        return false
    }

    func respond(request: Request, params: [String: String]) -> Response {
        return action(request: request, params: params)
    }

}

var stringRouter = Router<Route>()

stringRouter.register(
    Route(path: "/home", action: { request, params in
        print("")
        print("handled path:", request)
        print("params:", params)
        return true
    }),
    Route(path: "/something/:id/create", action: { request, params in
        print("")
        print("handled path:", request)
        print("params:", params)
        return true
    })
)

stringRouter.handle("/nothing")
stringRouter.handle("/home")
stringRouter.handle("/something/2/create")
stringRouter.handle("/something/22/create")
stringRouter.handle("whatever")

print("")
print("all registered routes:\n", stringRouter.friendlyRouteList)


struct Transformer<In, Out> {
    typealias ForwardTransformation = In -> Out
    typealias ReverseTransformation = Out -> In

    let transform: ForwardTransformation
    let reverse: ReverseTransformation?

    init(_ forward: ForwardTransformation) {
        self.transform = forward
        self.reverse = nil
    }

    init(_ forward: ForwardTransformation, reverse: ReverseTransformation) {
        self.transform = forward
        self.reverse = reverse
    }

    var canReverse: Bool {
        return reverse != nil
    }
}

// argument extraction/validation
struct ParamParser<Result> {
//    let mapping: [String: Result]
    let parse: ([String: String]) -> Result?
}

enum Action: String {
    case watch, buy, preview
}

struct ParamTransform<Out> {
    let process: String -> Out
}

let actionTransform = ParamTransform { actionString in
    return Action(rawValue: actionString)
}

actionTransform.process("buy")

//typealias MovieDetailActionData = (guid: Int, action: Action)
let movieDetailParser = ParamParser<(guid: Int, action: Action)>() { data in
    guard let guidString = data["guid"], guid = Int(guidString),
              actionString = data["action"], action = Action(rawValue: actionString) else { return nil }
    return (guid, action)
}

//typealias MovieDTA = movieDetailParser.resultType

stringRouter.register(
    Route(path: "/movie/:guid/:action", action: { request, parameters in
        guard let params = movieDetailParser.parse(parameters) else { return false }
        print("Matched movie detail route:", params.guid, params.action)
        return true
    })
)
stringRouter.handle("/movie/1234/nothing")
stringRouter.handle("/movie/1234/watch")

struct ParsedRoute<ParsedType>: RequestHandler {
    typealias Request = String
    typealias Response = Bool

    let path: String
    let parser: ParamParser<ParsedType>
//    let action: (request: Request, params: [String: String]) -> Response
    let action: (request: Request, params: ParsedType) -> Response

    static var defaultResponse: Response {
        return false
    }

    func respond(request: Request, params: [String: String]) -> Response {
        let parsedParams = parser.parse(params)!
        return action(request: request, params: parsedParams)
    }

}
//(key: "id")

"/movie/1234/nothing".componentsSeparatedByString("/")
"/movie/1234/nothing".unicodeScalars.split("/")
//movieDetailParser.resultType

//var parsedRouter = Router<ParsedRoute<movieDetailParser.ResultType>>()
var parsedRouter = Router<ParsedRoute<(guid: Int, action: Action)>>()

// I'd really like to move the parser logic into the routing itself, but I can't think of a way to make that work
// given that a collection of routes has to be a concrete type, and can't be made up of routes that
// have disparate types returned by the parser... Would love to find a solution that would allow for
// something more like the following instead of having to manually perform the parsing in each action block
parsedRouter.register(
    ParsedRoute(path: "/movie/:guid/:action", parser: movieDetailParser, action: { request, params in
        print("Matched movie detail route:", params.guid, params.action)
        return true
    })
)








