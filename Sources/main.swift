print("Let's fly 🛩")

// import Foundation
// import POSIXRegex
// import Core

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif
import HTTP
import Epoch
import CHTTPParser
import CLibvenice

struct EpochBridge: ResponderType {

    let app: FlyApp

    init(_ app: FlyApp) {
        self.app = app
    }

    func respond(request: Request) -> Response {
        let flyRequest = FlyRequest(request.uri.description)
        let (status, body) = app.router.handle(flyRequest).tuple
        let responseBody = body
        // if status == .NotFound {
        //     responseBody = "Page not found"
        // }
        print("received request:", request.uri.description, "-> \(status)")
        return Response(status: Status(statusCode: status.rawValue), body: responseBody)
    }
}

let app = App(config: Config())
let responder = EpochBridge(app)
let server = Server(port: 8080, responder: responder)

server.start()

