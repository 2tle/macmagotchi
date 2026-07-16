// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Macmagotchi",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "Macmagotchi", targets: ["Macmagotchi"])],
    targets: [.executableTarget(name: "Macmagotchi")]
)
