struct Config: FlyConfig {
    var environment = Environment.Development
}

class UserController {
    class func newUser(request: FlyRequest, response: FlyResponse) -> FlyResponse {
        return "New User Form"
    }

    class func createUser(request: FlyRequest, response: FlyResponse) -> FlyResponse {
        return "Creating a new user!"
    }
}

extension App {
    func setup() {
        router.route("/users/new", action: UserController.newUser)
        router.route("/users/create", method: .POST, action: UserController.createUser)

        router.route("/") { request, response in
            var response = response
            response.body = "Home page!"
            return response
        }

        // not sure I like this:
        router.GET("/welcome") { request, response in
            return "Welcome to our web page"
        }

        router.route("/welcome", method: .POST) { request, response in
            return "Why are you posting to /welcome?"
        }
    }
}
