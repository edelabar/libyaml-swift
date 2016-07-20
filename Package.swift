import PackageDescription

let package = Package(
    name: "YAML",
    dependencies: [
        .Package(url: "https://github.com/njdehoog/libyaml.git", majorVersion: 0, minor: 1)
    ]
)
