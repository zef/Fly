import Foundation

public typealias HTMLAttributes = [String: String]

public protocol Whitespaceable {
    var whitespace: Whitespace { get set }
}
//public extension Whitespaceable {
//    var whitespace: Whitespace { return .None }
//}

public protocol HTMLElement: Whitespaceable {
//public protocol HTMLElement {
    var htmlString: String { get }
}


extension String: HTMLElement {
    public var htmlString: String { return self }

    public var whitespace: Whitespace {
        get {
            return .None
        }
        set {
            //
        }
    }
}

public protocol HTMLView {
    var render: String { get }
}

public enum Whitespace {
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

    public mutating func combine(other: Whitespace) {
        switch other {
        case .Pre where self == .Post:
            self = .All
        case .Post where self == .Pre:
            self = .All
        default:
            self = other
        }
    }
}

//public struct HTMLContent: HTMLElement {
//
//    public var components = [HTMLElement]()
//    public var whitespace = Whitespace.None
//
//    public init(component: HTMLElement) {
//        self.components = [component]
//    }
//    public init(components: [HTMLElement]) {
//        self.components = components
//    }
//
//    public init(components: [HTMLElement], whitespace: Whitespace) {
//        self.components = components
//        self.whitespace = whitespace
//    }
//
//    public init(_ component: HTMLElement, whitespace: Whitespace) {
//        self.components = [component]
//        self.whitespace = whitespace
//    }
//
//    public var htmlString: String {
//        return components.map { $0.whitespace.pre + $0.htmlString + $0.whitespace.post }.joinWithSeparator("")
//    }
//}

public struct Tag: HTMLElement {

    public var type: String
    public var attributes = HTMLAttributes()
    public var content = [HTMLElement]()
    public var whitespace = Whitespace.None

    public init(_ type: String, id: String? = nil, classes: [String]? = nil, data: HTMLAttributes? = nil, attributes: HTMLAttributes = HTMLAttributes(), _ content: [HTMLElement]) {
        self.type = type
        self.attributes = combinedAttributes(attributes, id: id, classes: classes, data: data)
        self.content = content
    }

    public init(_ type: String, _ content: HTMLElement = "", id: String? = nil, classes: [String]? = nil, data: HTMLAttributes? = nil, attributes: HTMLAttributes = HTMLAttributes()) {
        self.type = type
        self.attributes = combinedAttributes(attributes, id: id, classes: classes, data: data)
        self.content = [content]
    }

//    public init(_ type: String, _ content: HTMLContent) {
//        self.type = type
//        self.content = content
//    }


    func combinedAttributes(attributes: HTMLAttributes, id: String?, classes: [String]?, data: HTMLAttributes?) -> HTMLAttributes {
        var attributes = attributes
        if let data = data {
            for (name, value) in data {
                attributes["data-\(name)"] = value
            }
        }
        if let classes = classes {
            attributes["class"] = classes.joinWithSeparator(" ")
        }
        if let id = id {
            attributes["id"] = id
        }
        return attributes
    }

    public var htmlString: String {
        let tag: String
        if isRaw {
            tag = contentString
        } else if isVoid {
            tag = "<\(type)\(attributeString) />"
        } else {
            tag = "<\(type)\(attributeString)>\(contentString)</\(type)>"
        }
        return whitespace.pre + tag + whitespace.post
    }

    public var isRaw: Bool {
        return type.isEmpty
    }

    static let voidElements = ["area", "base", "br", "col", "embed", "hr", "img", "input", "keygen", "link", "meta", "param", "source", "track", "wbr"]
    public var isVoid: Bool {
        return Tag.voidElements.contains(type)
    }

    private var contentString: String {
        return content.map { $0.htmlString }.joinWithSeparator("")
    }

    private var attributeString: String {
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

extension Tag: StringLiteralConvertible {
    public typealias UnicodeScalarLiteralType = StringLiteralType
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(stringLiteral: value)
    }

    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(stringLiteral: value)
    }

    public init(stringLiteral value: StringLiteralType) {
        self.init("", attributes: [:], [value])
    }
}

extension Tag: ArrayLiteralConvertible {
    public init(arrayLiteral elements: HTMLElement...) {
        self.init("", attributes: [:], elements)
    }
}