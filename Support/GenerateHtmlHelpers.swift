import Foundation

// let read = try! String(contentsOfFile: "/Users/zef/code/Fly/HTMLTags.swift")
func write(text: String, path: String) {
    do {
        try text.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
    } catch {
        print("file write failed")
    }
}

extension String {
    mutating func addLine(content: String, indent: Int = 0) {
        var indentation = ""
        for _ in 0..<indent where !content.isEmpty {
            indentation += "    "
        }
        self += "\n" + indentation + content
    }
    var quoted: String {
        return "\"\(self)\""
    }
}

struct TagDefinition {
    let tag: String

    static let voidElements = ["area", "base", "br", "col", "embed", "hr", "img", "input", "keygen", "link", "meta", "param", "source", "track", "wbr"]
    var isVoid: Bool {
        return TagDefinition.voidElements.contains(tag)
    }

    var methodDefinition: String {
        var def = ""

        if isVoid {
            def.addLine("public func \(tag.capitalizedString)(id id: String? = nil, classes: [String]? = nil, data: HTMLAttributes? = nil, attributes: HTMLAttributes = HTMLAttributes()) -> Tag {")
            def.addLine("return Tag(\(tag.quoted), \"\", id: id, classes: classes, data: data, attributes: attributes)", indent: 1)
            def.addLine("}")
        } else {
            def.addLine("public func \(tag.capitalizedString)(id id: String? = nil, classes: [String]? = nil, data: HTMLAttributes? = nil, attributes: HTMLAttributes = HTMLAttributes(), _ content: [HTMLElement]) -> Tag {")
            def.addLine("return Tag(\(tag.quoted), id: id, classes: classes, data: data, attributes: attributes, content)", indent: 1)
            def.addLine("}")

            def.addLine("public func \(tag.capitalizedString)(content: HTMLElement, id: String? = nil, classes: [String]? = nil, data: HTMLAttributes? = nil,  attributes: HTMLAttributes = HTMLAttributes()) -> Tag {")
            def.addLine("return Tag(\(tag.quoted), id: id, classes: classes, data: data, attributes: attributes, [content])", indent: 1)
            def.addLine("}")
        }

        def.addLine("")
        return def
    }
}


// to handle manually:
// a link img video input
// typealias TagConfig = (functionName: String, )

struct TagConfig {
    var function: String
    var attributes: (argument: String, type: String, default: String?)
}

// let tagConfiguration: [
//     // "a":
//     // "link":
//     // "input":
//     // "img":
//     // "video":
//     // "script":
// ]

let basicTagGroups = [
    "html head body",
    "div span",
    "article aside header footer nav main section",
    "h1 h2 h3 h4 h5 h6",
    "p strong em i",
    "ul ol li",
    "br hr",
]

var tags = basicTagGroups.reduce([TagDefinition]()) { tags, group in
    var tags = tags
    tags.appendContentsOf(group.componentsSeparatedByString(" ").map { TagDefinition(tag: $0) } )
    return tags
}

var code = "// This file is auto-generated, editing by hand is not recommended"
code.addLine("")
code.addLine("extension HTMLView {")
for tag in tags {
    for line in tag.methodDefinition.componentsSeparatedByString("\n") {
        code.addLine(line, indent: 1)
    }
}
code.addLine("}")

write(code, path: "HTMLViewTags.swift")
write(code, path: "../HTMLBuilder.playground/Sources/HTMLTags.swift")


