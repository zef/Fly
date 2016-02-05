//: [Previous](@previous)

//import Foundation

extension HTMLView {
//    public func Div(attributes attributes: HTMLAttributes = HTMLAttributes(), id: String? = nil, classes: [String]? = nil, data: HTMLAttributes? = nil, _ content: [HTMLElement]) -> Tag {
//        return Tag("div", id: id, classes: classes, data: data, attributes: attributes, content)
//    }
//    public func Div(content: HTMLElement, id: String? = nil, classes: [String]? = nil, data: HTMLAttributes? = nil,  attributes: HTMLAttributes = HTMLAttributes()) -> Tag {
//        return Tag("div", id: id, classes: classes, data: data, attributes: attributes, [content])
//    }
//    public func Div(attributes: HTMLAttributes = HTMLAttributes(), _ content: String) -> Tag {
//        return Tag("div", attributes: attributes, HTMLContent(component: content))
//    }
//    public func Div(content: String) -> Tag {
//        return Tag("div", attributes: [:], HTMLContent(component: content))
//    }
//
//    public func Link(to location: String, _ content: String) -> Tag {
//        return Tag("a", attributes: [:], HTMLContent(component: content))
//    }
}

//struct link: HTMLElement {
//    var tag: Tag
//
//    init(to location: String, attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent = "") {
//        var attributes = attributes
//        attributes["href"] = location
//        self.tag = Tag("a", attributes: attributes, content)
//    }
//    init(to location: String, _ content: HTMLContent = "") {
//        self.init(to: location, attributes: HTMLAttributes(), content)
//    }
//
//    var htmlString: String {
//        return tag.htmlString
//    }
//}

/////////////////////////

//prefix operator <~ {}
//prefix operator ~> {}
//prefix operator <~> {}


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

//prefix operator <> {}
//prefix func <> (string: String) -> Tag {
////    var tag = tag
////    tag.whitespace = .Post
//    return Tag("div", HTMLContent(component: string))
//}

//prefix operator >> {}
//prefix func >> (tag: Tag) -> Tag {
//    var tag = tag
//    tag.whitespace = .Post
//    return tag
//}
//

struct HTML5: HTMLView {

    var content: [HTMLElement]
//    var footerContent: [HTMLElement]

    var template: Tag {
        return [
            Html([
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
        ]
    }

    var render: String {
        return template.htmlString
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

//<<"SomeString"

print(SomeView().render)

