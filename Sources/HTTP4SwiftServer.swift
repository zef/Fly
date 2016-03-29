import http4swift
import Nest

extension String: PayloadType {
    public mutating func next() -> [UInt8]? {
        if self.isEmpty {
            return nil
        } else {
            let bytes = [UInt8](self.utf8)
            self = ""
            return bytes
        }
    }
}

struct NestResponse: ResponseType {
    var headers: [Header] { return [] }
    var body: PayloadType?
    var statusLine: String
}

extension FlyResponse {
    var nestResponse: NestResponse {
        return NestResponse(body: body, statusLine: status.description)
    }
}

public struct HTTP4SwiftServer: FlyServer {
    public static func start(app: FlyApp, port: Int) {
        let httpApp: Application = { (httpRequest) -> ResponseType in
            let path = httpRequest.path
            let method = HTTPMethod(rawValue: httpRequest.method) ?? .GET

            let request = FlyRequest(path, method: method)
            var response = app.router.handle(request)

            if response.status == 404 {
                if app.config.showDebugRoutes {
                    response.body = app.router.HTMLRouteList
                } else {
                    response.body = "Page Not Found"
                }
            }
            app.logRequest(request, response: response)
            return response.nestResponse
        }

        guard let server = HTTPServer(port: UInt16(port)) else {
            App.log("HTTPServer could not be started...")
            return
        }
        server.serve(httpApp)
    }

}


