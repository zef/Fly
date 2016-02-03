import struct http4swift.HTTPRequest
import struct http4swift.HTTPServer
import struct http4swift.SocketAddress
import struct http4swift.Socket

struct HTTP4SwiftServer: FlyServer {
    static func start(app: FlyApp, port: Int) {
        let address = SocketAddress(port: UInt16(port))
        guard let sock = Socket(), server = HTTPServer(socket: sock, addr: address) else { return }

        server.serve { (request, writer) in
            let (statusCode, statusText, body) = self.dataForRequest(app, request: request)

            let bytes = [UInt8](body.utf8)
            let size = bytes.filter({ $0 != 0 }).count
            try writer.write("HTTP/1.0 \(statusCode) \(statusText)\r\n")
            try writer.write("Content-Length: \(size)\r\n")
        //     for header in response!.headers {
        //         try writer.write("\(header.0): \(header.1)\r\n")
        //     }
            try writer.write("\r\n")
            try writer.write(body)
        }
    }

    static func dataForRequest(app: FlyApp, request httpRequest: http4swift.HTTPRequest) -> (Int, String, String) {
        // let time = NSDate()
        let path = httpRequest.path
        let method = HTTPMethod(rawValue: httpRequest.method) ?? .GET

        let request = FlyRequest(path, method: method)
        var response = app.router.handle(request)

        if response.status == .NotFound {
            if app.config.showDebugRoutes {
                response.body = app.router.HTMLRouteList
            } else {
                response.body = "Page Not Found"
            }
        }
        print("Received request:", request.method, request.path, "-> \(response.status)")
        // print("in \(time.timeIntervalSinceNow)")
        return (response.status.rawValue, "OK", response.body)
    }

}


