App.log("Let's fly 🛩")

let app = App(config: Config())
let server: FlyServer.Type = HTTP4SwiftServer.self
// let server: FlyServer.Type = EpochServer.self
server.start(app, port: 8080)

