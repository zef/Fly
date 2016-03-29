import HTTPStatus

public enum HTTPMethod: String {
    case GET, PUT, POST, DELETE
    // Patch?
}

public struct FlyRequest {
    public let path: String
    public let method: HTTPMethod
    public var parameters = [String: String]()

    public init(_ path: String, method: HTTPMethod = .GET) {
        self.path = path
        self.method = method
    }
}

public struct FlyResponse {
    public var request: FlyRequest = FlyRequest("")
    public var status: HTTPStatus = HTTPStatus.OK
    public var body: String = ""

    public init() { }
    public init(status: HTTPStatus) {
        self.status = status
    }
    public init(body: String) {
        self.body = body
    }
}

extension FlyResponse: StringLiteralConvertible {
    public typealias UnicodeScalarLiteralType = StringLiteralType
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(stringLiteral: value)
    }

    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(stringLiteral: value)
    }

    public init(stringLiteral value: StringLiteralType) {
        self.init(body: value)
    }
}


