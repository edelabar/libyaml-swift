import PackageDescription

let package = Package(
    name: "YAML",
    targets: [
        Target(
            name: "YAML",
            dependencies: ["LibYAML"]),
        Target(
            name: "LibYAML",
            dependencies: [])
    ]
)
