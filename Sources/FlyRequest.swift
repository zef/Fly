enum HTTPMethod: String {
    case GET, PUT, POST, DELETE
    // Patch?
}

struct FlyRequest {
    let path: String
    let method: HTTPMethod
    var parameters = [String: String]()

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


