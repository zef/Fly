import Foundation

struct RouteParser<ReturnValue> {
    typealias Options = [String: String]
    let path: String
    let extractor: (Options) -> ReturnValue?

    init(path: String, extractor: (Options) -> ReturnValue?) {
        self.path = path
        self.extractor = extractor
    }

    func match(requestPath: String) -> ReturnValue? {
        guard let data = dataForPath(path: requestPath) else { return nil }
        return extractor(data)
    }

    func dataForPath(path requestPath: String) -> Options? {
        let templateComponents = path.componentsSeparatedByString("/")
        let pathComponents = requestPath.componentsSeparatedByString("/")

        let valueIdentifiers = templateComponents.reduce([String]()) { result, component in
            var result = result
            if component.characters.first == ":" {
                result.append(component)
            }
            return result
        }
        let valueIndices = valueIdentifiers.flatMap { templateComponents.indexOf($0) }

        var data = Options()
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

// swift compiler can almost infer this, but not with optionals
typealias RoleData = (id: Int, role: String)
let parser = RouteParser<RoleData>(path: "/users/:id/add_role/:role") { data in
    guard let idString = data["id"], id = Int(idString), role = data["role"] else { return nil }
    return (id: id, role: role)
}

if let match = parser.match("/users/12/add_role/admin") {
    match.id
    match.role
}

if let match = parser.match("/users/12/create") {
    match.id
    match.role
}

enum Action: String {
    case watch, share, play
}

typealias TargetActionData = (target: String, action: Action)
let targetParser = RouteParser<TargetActionData>(path: "/:target/:action") { data in
    guard let target = data["target"], actionString = data["action"], action = Action(rawValue: actionString) else { return nil }
    return (target: target, action: action)
}

targetParser.match("/whatever")
targetParser.match("/movie/play")
targetParser.match("/video/invalid")
targetParser.match("/video/share")
targetParser.match("/thing/share/extra_arg")

//let parsed = ParseResult(path: "/users/12/add_role/admin")
//let parsed2 = ParseResult(path: "/users/12/admin")
