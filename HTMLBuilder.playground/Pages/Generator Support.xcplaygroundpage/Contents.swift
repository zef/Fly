
prefix operator << {}
prefix func <<(tag: Tag) -> Tag {
    var tag = tag
    tag.whitespace.combine(.Pre)
    return tag
}

postfix operator >> {}
postfix func >>(tag: Tag) -> Tag {
    var tag = tag
    tag.whitespace.combine(.Post)
    return tag
}

prefix operator <<>> {}
prefix func <<>>(tag: Tag) -> Tag {
    var tag = tag
    tag.whitespace = .All
    return tag
}


struct HTML5: HTMLView {
    let doctype = "<!DOCTYPE html>"
    var content: [HTMLElement]
//    var footerContent: [HTMLElement]

    var template: Tag {
        return Html([
            Head([

            ]),
            Body([
                Header([
                    Nav([
                        Li("Sign Up"),
                        Li("Sign In")
                    ])
                ]),
                Section(content),
                Hr(classes: ["very-nice"]),
                Footer([])
            ])
        ])
    }

    var render: String {
        return doctype + template.htmlString
    }
}


struct SomeView: HTMLView {
    let product = "Fly"
    let subtitle = "A high-level Swift web framework."
    let bulletPoints = [
        "Swift is really great",
        "There are some cool things we could do with Swift",
        "Especially now that you can run it on linux",
    ]
    let template = HTML5.self

    var content: [HTMLElement] {
        return [
            H1(product),
            <<H3(subtitle)>>,
            P("I really hope you like it"),
            Ul(classes: ["bullet-list"],
                bulletPoints.map { Li($0) }
            ),
            Div("Raw String", classes: ["one", "two"]),
            <<>>Div("lots of stuff", data: ["toggle": "true"], classes: ["one", "two"], attributes: ["hey": "there"]),
            Div("Raw String", id: "yes", data: ["toggle": "true"], classes: ["one", "two"], attributes: ["hey": "there"]),
            Div("String with attributes", attributes: ["whatever": "is great"]),
        ]
    }

    var render: String {
        return template.init(content: content).render
    }
}

print(SomeView().render)

