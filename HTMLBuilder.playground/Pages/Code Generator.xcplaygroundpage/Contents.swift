//: [Previous](@previous)

import Foundation

extension String {
    mutating func addLine(content: String, indent: Int = 0) {
        var indentation = ""
        for _ in 0..<indent {
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
        def.addLine("func \(tag)(attributes: HTMLAttributes = HTMLAttributes(), _ content: HTMLContent) -> Tag {")
        def.addLine("return Tag(\(tag.quoted), attributes: attributes, content)", indent: 1)
        def.addLine("}")

        def.addLine("func \(tag)(attributes: HTMLAttributes = HTMLAttributes(), _ content: String) -> Tag {")
        def.addLine("return Tag(\(tag.quoted), attributes: attributes, HTMLContent(content))", indent: 1)
        def.addLine("}")

        def.addLine("")
        return def
    }
    var structDefinition: String {
        var def = "\n"
        def += "struct \(tag): HTMLTag {"
        def += ""
        def += ""
        def += ""
        def += ""
        def += ""
        def += ""
        def += "}"
        return def
    }
}


// handle specifically:
// a link img video input

let basicTagGroups = [
    "html head body",
    "div span",
    "article aside header nav main section",
    "h1 h2 h3 h4 h5 h6",
    "p strong em i",
    "ul ol li",
]

var tags = basicTagGroups.reduce([TagDefinition]()) { tags, group in
    var tags = tags
    tags.appendContentsOf(group.componentsSeparatedByString(" ").map { TagDefinition(tag: $0) } )
    return tags
}

tags

//let basicTags = [ ]


//var tags: [TagDefinition] = [
//    TagDefinition(tag: "a")
//]

print("extension HTMLView {")
for tag in tags {
    for line in tag.methodDefinition.componentsSeparatedByString("\n") {
        print("    ", line)
    }
}
print("}")





//: [Next](@next)
