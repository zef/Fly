import PackageDescription

let package = Package(
    name: "Fly",
    dependencies: [
        // .Package(url: "https://github.com/Zewo/POSIXRegex.git", majorVersion: 0, minor: 1),
        // .Package(url: "https://github.com/Zewo/Core.git", majorVersion: 0, minor: 1),
        // .Package(url: "https://github.com/Zewo/PostgreSQL.git", majorVersion: 0)
        // .Package(url: "https://github.com/Zewo/Epoch.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/takebayashi/http4swift.git", Version(0, 0, 6))
    ]
)

