typealias HTMLAttributes = [String: String]

enum TagType {
    // I'd like to decide about using a single case some tags vs supporting multiple options
    // like Br vs Break, and also Link. I kinda prefer the more human-readable versions, but they
    // also require more learning and abstraction since they're a departure from the standard.
    case HTML, Head, Body
    case Div, Span
    case Br, Break
    case Link(to: String)
    case Ul, Li
    case Img(src: String)

    var tagName: String {
        switch self {
        case .HTML:
            return "html"
        case .Head:
            return "head"
        case .Body:
            return "body"
        case .Div:
            return "div"
        case .Br, .Break:
            return "br"
        case .Span:
            return "span"
        case .Link:
            return "a"
        case .Ul:
            return "ul"
        case .Li:
            return "li"
        case .Img:
            return "img"
        }
    }

    // self-closing tags are called Void elements: http://www.w3.org/TR/html5/syntax.html#void-elements
    static let voidElements = ["area", "base", "br", "col", "embed", "hr", "img", "input", "keygen", "link", "meta", "param", "source", "track", "wbr"]
    var isVoid: Bool {
        return TagType.voidElements.contains(tagName)
    }

    var attributes: HTMLAttributes {
        var attributes = HTMLAttributes()

        switch self {
        case .Link(let href):
            attributes["href"] = href
        case .Img(let src):
            attributes["src"] = src
        default:
            break
        }

        return attributes
    }
}

protocol HTMLTag {
    var htmlString: String { get }
}

extension String: HTMLTag {
    var htmlString: String { return self }
}

//protocol HTMLContent {}

struct Tag: HTMLTag {

    var type: TagType
    var attributes = HTMLAttributes()
    var contentItems = [HTMLTag]()

    init(_ type: TagType, attributes: HTMLAttributes = HTMLAttributes(), _ content: String = "") {
        self.type = type
        self.attributes = attributes
        self.contentItems = [content]
    }

    init(_ type: TagType, htmlTags: [HTMLTag]) {
        self.type = type
        self.contentItems = htmlTags
    }

    var htmlString: String {
        let content = contentItems.map { $0.htmlString }.joinWithSeparator("")
        let tagName = type.tagName
        if type.isVoid {
            return "<\(tagName)\(attributeString) />"
        } else {
            return "<\(tagName)\(attributeString)>\(content)</\(tagName)>"
        }
    }

    var attributeString: String {
        var allAttributes = attributes
        for (key, value) in type.attributes {
            allAttributes[key] = value
        }

        guard !allAttributes.isEmpty else { return "" }
        return allAttributes.reduce("", combine: { (result, pair) -> String in
            var result = result
            let (key, value) = pair
            // TODO: escape quotes in value
            result += " \(key)=\"\(value)\""
            return result
        })
    }

    var description: String {
        return htmlString
    }
}

struct HTML5: HTMLTag {
    var tag: Tag

    init(_ tags: [HTMLTag]) {
        let content = tags.map { $0.htmlString }.joinWithSeparator("")

        self.tag = Tag(.HTML, htmlTags: [
            Tag(.Head, ""),
            // Tag(.Body, tags.htmlString),
            Tag(.Body, content),
        ])
    }

    var htmlString: String {
        return tag.htmlString
    }
}
// would be really tedious to implement a bunch of these... maybe autogenerate them based on attributes?
struct Link: HTMLTag {
    var tag: Tag

    init(_ location: String, attributes: HTMLAttributes = HTMLAttributes(), _ content: String = "") {
        self.tag = Tag(.Link(to: location), attributes: attributes, content)
    }
    init(_ location: String, _ content: String = "") {
        self.tag = Tag(.Link(to: location), content)
    }

    var htmlString: String {
        return tag.htmlString
    }
}

