// #if os(Linux)
//     import Glibc
// #else
//     import Darwin.C
// #endif

// import HTTP
// import Epoch
// import CHTTPParser
// import CLibvenice

// struct EpochServer: FlyServer {

//     static func start(app: FlyApp, port: Int) {
//         let responder = Responder(app)
//         let server = Server(port: port, responder: responder)
//         server.start()
//     }

//     struct Responder: ResponderType {
//         let app: FlyApp

//         init(_ app: FlyApp) {
//             self.app = app
//         }

//         func respond(request: Request) -> Response {
//             let flyRequest = FlyRequest(request.uri.description)
//             let response = app.router.handle(flyRequest)
//             var responseBody = response.body
//             if response.status == .NotFound {
//                 if app.config.showDebugRoutes {
//                     responseBody = app.router.HTMLRouteList
//                 } else {
//                     responseBody = "Page Not Found"
//                 }
//             }
//             print("Received request:", request.uri.description, "-> \(response.status)")
//             return Response(status: Status(statusCode: response.status.rawValue), body: responseBody)
//         }
//     }
// }



