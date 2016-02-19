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
    let functionName: String
    let tag: String
    var arguments: [Argument]

    static let voidElements = ["area", "base", "br", "col", "embed", "hr", "img", "input", "keygen", "link", "meta", "param", "source", "track", "wbr"]
    var isVoid: Bool {
        return TagDefinition.voidElements.contains(tag)
    }

    var methodDefinition: String {
        var def = ""

        let args = TagDefinition.defaultArguments
        if isVoid {
            // def.addLine("public func \(tag.capitalizedString)(id id: String? = nil, classes: [String]? = nil, data: HTMLAttributes? = nil, attributes: HTMLAttributes = HTMLAttributes()) -> Tag {")
            def.addLine("public func \(tag.capitalizedString)(\(Argument.constructString(args))) -> Tag {")
            def.addLine("return Tag(\(tag.quoted), \"\", id: id, classes: classes, data: data, attributes: attributes)", indent: 1)
            def.addLine("}")
        } else {
            var contentArg = Argument(label: "content", type: "[HTMLElement]", isOptional: false, defaultValue: nil, requireLabel: false, addToAttributes: false)
            var contentSuffixArgs = args
            contentSuffixArgs.append(contentArg)

            def.addLine("public func \(tag.capitalizedString)(\(Argument.constructString(contentSuffixArgs))) -> Tag {")
            def.addLine("return Tag(\(tag.quoted), id: id, classes: classes, data: data, attributes: attributes, content)", indent: 1)
            def.addLine("}")

            // var attributes = attributes
            // // for
            // "attributes[\"\(argument.label)\"] = \(argument.label)"

            var contentPrefixArgs = args
            contentArg.type = "HTMLElement"
            contentPrefixArgs.insert(contentArg, atIndex: 0)
            def.addLine("public func \(tag.capitalizedString)(\(Argument.constructString(contentPrefixArgs))) -> Tag {")
            def.addLine("return Tag(\(tag.quoted), id: id, classes: classes, data: data, attributes: attributes, [content])", indent: 1)
            def.addLine("}")
        }

        // id: String? = nil, classes: [String]? = nil, data: HTMLAttributes? = nil,  attributes: HTMLAttributes = HTMLAttributes()

        def.addLine("")
        return def
    }


    static var defaultArguments: [Argument] {
        return [
            Argument(label: "id", type: "String", isOptional: true, defaultValue: "nil", requireLabel: true, addToAttributes: false),
            Argument(label: "classes", type: "[String]", isOptional: true, defaultValue: "nil", requireLabel: true, addToAttributes: false),
            Argument(label: "data", type: "HTMLAttributes", isOptional: true, defaultValue: "nil", requireLabel: true, addToAttributes: false),
            Argument(label: "attributes", type: "HTMLAttributes", isOptional: false, defaultValue: "HTMLAttributes()", requireLabel: true, addToAttributes: false)
        ]
    }
}

struct Argument {
    var label: String
    var type: String
    var isOptional: Bool
    var defaultValue: String?
    var requireLabel = true

    var addToAttributes = false

    func string(isFirstArgument: Bool) -> String {
        var prefixString = ""
        if requireLabel {
            if isFirstArgument {
                prefixString = "\(label) "
            }
        } else {
            if !isFirstArgument {
                prefixString = "_ "
            }
        }


        let optionalString = isOptional ? "?" : ""
        var defaultString = ""
        if let defaultValue = defaultValue {
            defaultString = " = \(defaultValue)"
        }

        return "\(prefixString)\(label): \(type)\(optionalString)\(defaultString)"
    }

    static func constructString(arguments: [Argument]) -> String {
        var strings = [String]()
        for (index, argument) in arguments.enumerate() {
            let isFirst = index == 0
            strings.append(argument.string(isFirst))
        }
        return strings.joinWithSeparator(", ")
    }
}



// to handle manually:
// a link img video input

let customTags = [
    // TagDefinition(functionName: "Link", tag: "a", arguments: [
    //     Argument(label: "to", type: "String", isOptional: false, defaultValue: nil, requireLabel: true, addToAttributes: true)
    // ])
    // "a": TagConfig(function: "Link", , type: "a")
    // "link":
    // "input": "type"
    // "img": "src", "alt"
    // "video":
    // "script":
]

// text|password|checkbox|radio|submit|reset|file|hidden|image|button

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
    tags.appendContentsOf(group.componentsSeparatedByString(" ").map { TagDefinition(functionName: $0.capitalizedString, tag: $0, arguments: []) } )
    // tags.appendContentsOf(customTags)
    return tags
}

var code = "// This file is auto-generated, editing by hand is not recommended"
code.addLine("")
code.addLine("extension HasHTML {")
for tag in tags {
    for line in tag.methodDefinition.componentsSeparatedByString("\n") {
        code.addLine(line, indent: 1)
    }
}
code.addLine("}")

write(code, path: "HTMLViewTags.swift")
write(code, path: "../Sources/HTMLTags.swift")
write(code, path: "../HTMLBuilder.playground/Sources/HTMLTags.swift")

