import PackageDescription

let package = Package(
    name: "KituraRequest",
    dependencies: [
            .Package(url: "https://github.com/michalkalinowski-/Kitura-net.git", majorVersion: 0, minor: 17),
        ]
)
