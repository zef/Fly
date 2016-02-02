//: [Previous](@previous)

import Foundation

typealias HTMLAttributes = [String: String]

protocol HTMLElement {
    var htmlString: String { get }
    var whitespace: HTMLContent.Whitespace { get }
}

extension HTMLElement {
    var whitespace: HTMLContent.Whitespace { return .None }
}

extension String: HTMLElement {
    var htmlString: String { return self }
}

struct HTMLContent: HTMLElement {
    enum Whitespace {
        case None, Pre, Post, All

        var pre: String {
            switch self {
            case .Pre, .All:
                return " "
            default:
                return ""

            }
        }

        var post: String {
            switch self {
            case .Post, .All:
                return " "
            default:
                return ""

            }
        }
    }

    var components = [HTMLElement]()
    var whitespace = Whitespace.None

    init(component: HTMLElement) {
        self.components = [component]
    }
    init(components: [HTMLElement]) {
        self.components = components
    }

    init(components: [HTMLElement], whitespace: Whitespace) {
        self.components = components
        self.whitespace = whitespace
    }

    init(_ component: HTMLElement, whitespace: Whitespace) {
        self.components = [component]
        self.whitespace = whitespace
    }

    var htmlString: String {
        return components.map { $0.whitespace.pre + $0.htmlString + $0.whitespace.post }.joinWithSeparator("")
    }
}



extension HTMLContent: StringLiteralConvertible {
    typealias UnicodeScalarLiteralType = StringLiteralType
    init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(stringLiteral: value)
    }

    typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(stringLiteral: value)
    }

    init(stringLiteral value: StringLiteralType) {
        self.init(components: [value])
    }
}


extension HTMLContent: ArrayLiteralConvertible {
    init(arrayLiteral elements: HTMLElement...) {
        self.init(components: elements)
    }
}

struct Tag: HTMLElement {

    var type: String
    var attributes = HTMLAttributes()
    var content = HTMLContent()

    init(_ type: String, attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent = HTMLContent()) {
        self.type = type
        self.attributes = attributes
        self.content = content
    }

    init(_ type: String, _ content: HTMLContent) {
        self.type = type
        self.content = content
    }

    var htmlString: String {
        if isVoid {
            return "<\(type)\(attributeString) />"
        } else {
            return "<\(type)\(attributeString)>\(content.htmlString)</\(type)>"
        }
    }

    static let voidElements = ["area", "base", "br", "col", "embed", "hr", "img", "input", "keygen", "link", "meta", "param", "source", "track", "wbr"]
    var isVoid: Bool {
        return Tag.voidElements.contains(type)
    }

    var attributeString: String {
        guard !attributes.isEmpty else { return "" }
        return attributes.reduce("", combine: { (result, pair) -> String in
            var result = result
            let (key, value) = pair
            // TODO: escape quotes and other chars in value
            result += " \(key)=\"\(value)\""
            return result
        })
    }

    var description: String {
        return htmlString
    }
}

struct link: HTMLElement {
    var tag: Tag

    init(_ location: String, attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent = "") {
        var attributes = attributes
        attributes["href"] = location
        self.tag = Tag("a", attributes: attributes, content)
    }
    init(_ location: String, _ content: HTMLContent = "") {
        self.init(location, attributes: HTMLAttributes(), content)
    }

    var htmlString: String {
        return tag.htmlString
    }
}

/////////////////////////
protocol HTMLView {
    var render: String { get }
}


extension HTMLView {
    func html(attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
        return Tag("html", attributes: attributes, content)
    }

    func head(attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
        return Tag("head", attributes: attributes, content)
    }

    func body(attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
        return Tag("body", attributes: attributes, content)
    }

    func article(attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
        return Tag("article", attributes: attributes, content)
    }

    func aside(attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
        return Tag("aside", attributes: attributes, content)
    }

    func header(attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
        return Tag("header", attributes: attributes, content)
    }

    func nav(attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
        return Tag("nav", attributes: attributes, content)
    }

    func main(attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
        return Tag("main", attributes: attributes, content)
    }

    func section(attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
        return Tag("section", attributes: attributes, content)
    }

    func h1(content: String) -> Tag {
        return Tag("h1", attributes: [:], HTMLContent(component: content))
    }
    func h1(content: HTMLContent) -> Tag {
        return Tag("h1", attributes: [:], content)
    }
    func h1(attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
        return Tag("h1", attributes: attributes, content)
    }
    func h1(attributes: HTMLAttributes = HTMLAttributes(), _ content: String) -> Tag {
        return Tag("h1", attributes: attributes, HTMLContent(component: content))
    }

    func h2(attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
        return Tag("h2", attributes: attributes, content)
    }

    func h3(attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
        return Tag("h3", attributes: attributes, content)
    }

    func h4(attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
        return Tag("h4", attributes: attributes, content)
    }

    func h5(attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
        return Tag("h5", attributes: attributes, content)
    }

    func h6(attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
        return Tag("h6", attributes: attributes, content)
    }

    func p(attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
        return Tag("p", attributes: attributes, content)
    }

    func strong(attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
        return Tag("strong", attributes: attributes, content)
    }

    func em(attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
        return Tag("em", attributes: attributes, content)
    }

    func i(attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
        return Tag("i", attributes: attributes, content)
    }

    func ul(attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
        return Tag("ul", attributes: attributes, content)
    }

    func ol(attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
        return Tag("ol", attributes: attributes, content)
    }

    func li(attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
        return Tag("li", attributes: attributes, content)
    }
    func test(attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent = "") -> Tag {
        return Tag("test", attributes: attributes, content)
    }
    func test(content: HTMLContent = "") -> Tag {
        return Tag("test", attributes: HTMLAttributes(), content)
    }

    func p(attributes: HTMLAttributes = HTMLAttributes(), _ content: String) -> Tag {
        return Tag("p", attributes: attributes, HTMLContent(component: content))
    }


}



struct SomeView: HTMLView {
    let title = "Article Title"
    let body = "This is my article. I hope you like it a lot!"

    var render: String {
        let content: HTMLContent = [
//            test(["Some": "value"], "stuff"),
//            test(["other": "values"]),
            test("stuff"),
            test([
                article([:], [
                    h1(title),
                    p(["class": "big"], body)
                ])
            ])
//            ul("content")
//            Tag("span", attributes: ["some": "value"], "some string")
//            ul(attributes: ["class": "one two three"], [
////                div(attributes: ["class": "value"], "hi")
////                li("some"), li("stuff")
//            ]),
//            div("hey there"),
            //            div("hey there"),
            //            div("hey there"),
        ]
        return content.htmlString
    }
}

SomeView().render

let string = "SomeClassName"
string.capitalizedString

extension String {
    var lowercaseFirstLetter: String {
        guard let character = characters.first else { return self }
        let range = self.startIndex...self.startIndex
        return self.stringByReplacingCharactersInRange(range, withString: String(character).lowercaseString)
    }
}

string.lowercaseFirstLetter




