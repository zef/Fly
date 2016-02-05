//: Playground - noun: a place where people can play

import UIKit

//protocol HTMLElement {
//    var htmlString: String { get }
//    var whitespace: HTMLContent.Whitespace { get }
//}
//
//extension HTMLElement {
//    var whitespace: HTMLContent.Whitespace { return .None }
//}
//
//extension String: HTMLElement {
//    var htmlString: String { return self }
//}
//
//struct HTMLContent: HTMLElement {
//    enum Whitespace {
//        case None, Pre, Post, All
//
//        var pre: String {
//            switch self {
//            case .Pre, .All:
//                return " "
//            default:
//                return ""
//
//            }
//        }
//
//        var post: String {
//            switch self {
//            case .Post, .All:
//                return " "
//            default:
//                return ""
//
//            }
//        }
//    }
//
//    var components = [HTMLElement]()
//    var whitespace = Whitespace.None
//
//    init(component: HTMLElement) {
//        self.components = [component]
//    }
//    init(components: [HTMLElement]) {
//        self.components = components
//    }
//
//    init(components: [HTMLElement], whitespace: Whitespace) {
//        self.components = components
//        self.whitespace = whitespace
//    }
//
//    init(_ component: HTMLElement, whitespace: Whitespace) {
//        self.components = [component]
//        self.whitespace = whitespace
//    }
//
//    var htmlString: String {
//        return components.map { $0.whitespace.pre + $0.htmlString + $0.whitespace.post }.joinWithSeparator("")
//    }
//}
//
//
//
//extension HTMLContent: StringLiteralConvertible {
//    typealias UnicodeScalarLiteralType = StringLiteralType
//    init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
//        self.init(stringLiteral: value)
//    }
//
//    typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
//    init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
//        self.init(stringLiteral: value)
//    }
//
//    init(stringLiteral value: StringLiteralType) {
//        self.init(components: [value])
//    }
//}
//
//
//extension HTMLContent: ArrayLiteralConvertible {
//    init(arrayLiteral elements: HTMLElement...) {
//        self.init(components: elements)
//    }
//}
//
//let content: HTMLContent = ["one", HTMLContent("two", whitespace: .All), "three"]
//content.htmlString
//
//
//typealias HTMLAttributes = [String: String]
//
//enum TagType {
//    case Div, Span
//    case Link(to: String)
//    case Ul, Li
//    case Img(src: String)
//
//    var tagName: String {
//        switch self {
//        case .Div:
//            return "div"
//        case .Span:
//            return "span"
//        case .Link:
//            return "a"
//        case .Ul:
//            return "ul"
//        case .Li:
//            return "li"
//        case .Img:
//            return "img"
//        }
//    }
//
//    // self-closing tags are called Void elements: http://www.w3.org/TR/html5/syntax.html#void-elements
//    static let voidElements = ["area", "base", "br", "col", "embed", "hr", "img", "input", "keygen", "link", "meta", "param", "source", "track", "wbr"]
//    var isVoid: Bool {
//        return TagType.voidElements.contains(tagName)
//    }
//
//    var attributes: HTMLAttributes {
//        var attributes = HTMLAttributes()
//
//        switch self {
//        case .Link(let href):
//            attributes["href"] = href
//        case .Img(let src):
//            attributes["src"] = src
//        default:
//            break
//        }
//
//        return attributes
//    }
//}
//
//
//struct Tag: HTMLElement {
//
//    var type: TagType
//    var attributes = HTMLAttributes()
//    var content = HTMLContent()
//
//    init(_ type: TagType, attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent = HTMLContent()) {
//        self.type = type
//        self.attributes = attributes
//        self.content = content
//    }
//
//    init(_ type: TagType, _ content: HTMLContent) {
//        self.type = type
//        self.content = content
//    }
//
//    var htmlString: String {
//        let tagName = type.tagName
//        if type.isVoid {
//            return "<\(tagName)\(attributeString) />"
//        } else {
//            return "<\(tagName)\(attributeString)>\(content.htmlString)</\(tagName)>"
//        }
//    }
//
//    var attributeString: String {
//        var allAttributes = attributes
//        for (key, value) in type.attributes {
//            allAttributes[key] = value
//        }
//
//        guard !allAttributes.isEmpty else { return "" }
//        return allAttributes.reduce("", combine: { (result, pair) -> String in
//            var result = result
//            let (key, value) = pair
//            // TODO: escape quotes in value
//            result += " \(key)=\"\(value)\""
//            return result
//        })
//    }
//
//    var description: String {
//        return htmlString
//    }
//}
//
//// would be really tedious to implement a bunch of these... maybe autogenerate them based on attributes?
////struct Link: HTMLElement {
////    var tag: Tag
////
////    init(_ location: String, attributes: HTMLAttributes = HTMLAttributes(), _ content: String = "") {
////        self.tag = Tag(.Link(to: location), attributes: attributes, content)
////    }
////    init(_ location: String, _ content: String = "") {
////        self.tag = Tag(.Link(to: location), content)
////    }
////
////    var htmlString: String {
////        return tag.htmlString
////    }
////}
//
////Link("http://whatever", "Hey there").htmlString
////Link("http://whatever", attributes: HTMLAttributes(), "Hey there").htmlString
////
////Tag(.Img(src: "http://apple.com/image.jpg")).htmlString
////Tag(.Div, "Hey There").htmlString
////
////Tag(.Ul, htmlTags: [
////    Tag(.Li, htmlTags: [
////        Link("/users/sign-up", attributes: ["whatever": "other stuff"], "Sign Up")
////    ]),
////    Tag(.Li, "one"),
////    Tag(.Li, "two"),
////    Tag(.Li, "three"),
////]).htmlString
//
//
//
//protocol HTMLView {
//    var render: String { get }
//}
//
//extension HTMLView {
////    func div(attributes attributes: HTMLAttributes = HTMLAttributes(), _ string: String) -> Tag {
////        return Tag(.Div, attributes: attributes, HTMLContent(component: string))
////    }
//    func ul(attributes attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
//        return Tag(.Ul, attributes: attributes, content)
//    }
//    func li(attributes attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
//        return Tag(.Li, attributes: attributes, content)
//    }
//    func div(attributes attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {
//        return Tag(.Div, attributes: attributes, content)
//    }
//
//    static func addClasses() {
//
//    }
//
//}
//
//
//struct SomeView: HTMLView {
//    let title = "The Martian"
//
//    var render: String {
//        let content: HTMLContent = [
//            ul(attributes: ["class": "one two three"], [
//                li("some"), li("stuff")
//            ]),
//            div("hey there"),
////            div("hey there"),
////            div("hey there"),
//        ]
//        return content.htmlString
//    }
//}
//
//
//
//SomeView().render
//


