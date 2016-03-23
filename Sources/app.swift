import SwifTML

struct Config: FlyConfig {
    var environment = Environment.Development
}

extension App {
    func setup() {
        router.route("/users/new", action: UserController.new)
        router.route("/users/:id", action: UserController.show)
        router.route("/users/create", method: .POST, action: UserController.create)

        // not sure I like the .GET thing:
        router.get("/welcome") { request, response in
            return "Welcome to our web page"
        }

        router.route("/welcome", method: .POST) { request, response in
            return "Why are you posting to /welcome?"
        }

        struct HomeView: HTMLView {
            var render: String {
                return HTML5(head: [], body: [
                    H1("Fly"),
                    H3("A web framework for Swift."),
                ]).render
            }
        }

        router.route("/") { request, response in
            var response = response
            response.body = HomeView().render
            return response
        }

        struct SwifTMLView: HTMLView {
            func Jumbotron(elements: [HTMLElement]) -> HTMLElement {
                return Div(classes: ["container"], [
                    Div(classes: ["jumbotron"], elements)
                ])

            }

            var render: String {
                return HTML5(
                    head: [
                        Meta(attributes: ["charset": "utf-8"]),
                        Meta(attributes: ["name":"viewport", "content":"width=device-width, initial-scale=1"]),
                        Title("SwifTML | HTML Builder for Swift"),
                        Stylesheet(at: "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css", attributes: [
                            "integrity": "sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7",
                            "crossorigin": "anonymous"
                        ])
                    ],
                    body: [
                        Div(classes: ["container"], [
                            Jumbotron([
                                H1("SwifTML"),
                                Link("Check it out on GitHub", to: "https://github.com/zef/SwifTML")
                            ]),
                            Hr(),
                            Footer(P("That's all. You can go home."), classes: ["footer"])
                        ])
                    ]
                ).render
            }
        }
        router.route("/SwifTML") { request, response in
            var response = response
            response.body = SwifTMLView().render
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
        response.body = ShowView(id: id).render
        // return HTML5(head: [], body: [
        //     H1("Showing User"),
        //     Div("User ID: \(id)"),
        // ]).render
        return response
    }

    struct ShowView: HTMLView {
        let id: String

        var render: String {
            return HTML5(head: [], body: [
                H1("Showing User"),
                Div("User ID: \(id)"),
            ]).render
        }
    }
}

