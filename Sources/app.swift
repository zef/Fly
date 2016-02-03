struct Config: FlyConfig {
    var environment = Environment.Development
}

extension App {
    func setup() {
        router.route("/users/new", action: UserController.new)
        router.route("/users/:id", action: UserController.show)
        router.route("/users/create", method: .POST, action: UserController.create)

        // not sure I like this:
        router.GET("/welcome") { request, response in
            return "Welcome to our web page"
        }

        router.route("/welcome", method: .POST) { request, response in
            return "Why are you posting to /welcome?"
        }

        router.route("/") { request, response in
            var response = response
            response.body = HTML5([Tag(.Div, "Home page!")]).htmlString
            return response
        }

    }
}

class UserController {
    class func new(request: FlyRequest, response: FlyResponse) -> FlyResponse {
        return "New User Form"
    }

    class func create(request: FlyRequest, response: FlyResponse) -> FlyResponse {
        return "Creating a new user!"
    }

    class func show(request: FlyRequest, response: FlyResponse) -> FlyResponse {
        let id = request.parameters["id"] ?? ""
        var response = response
        response.body = HTML5([
            Tag(.H1, "Showing User"),
            Div("Got user ID: \(id)")
        ]).htmlString
        return response
    }
}
