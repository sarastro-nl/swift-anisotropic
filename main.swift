import Foundation

do {
    try shell("convert --version")
} catch {
    print("convert is missing\n\nPlease install imagemagick with `brew install imagemagick`")
    exit(1)
}

guard CommandLine.arguments.count == 2 else {
    print("argument missing")
    exit(1)
}

let file = CommandLine.arguments[1]

guard FileManager.default.fileExists(atPath: file) else {
    print("no such file: \(file)")
    exit(1)
}

let width = Int(try shell("identify -format '%w' \(file)"))!
let height = Int(try shell("identify -format '%h' \(file)"))!
let min = width < height ? width : height

try shell("convert \(file) -gravity center -extent \(min)x\(min) square.ppm")
try shell("convert -size 512x512 xc: \(file).ppm")

var yposition = 0
for i in (0...8).reversed() {
    let yscale = 1 << i
    var xposition = 0
    for j in (0...8).reversed() {
        let xscale = 1 << j
        try shell("convert \(file).ppm square.ppm -geometry \(xscale)x\(yscale)!+\(xposition)+\(yposition) -composite -depth 8 \(file).ppm")
        xposition += xscale
    }
    yposition += yscale
}

try? FileManager.default.removeItem(atPath: "square.ppm")

@discardableResult
func shell(_ command: String) throws -> String {
    let task = Process()
    let pipeOutput = Pipe()
    let pipeError = Pipe()

    task.launchPath = "/bin/bash"
    task.arguments = ["-c", command]
    task.standardInput = nil
    task.standardOutput = pipeOutput
    task.standardError = pipeError
    task.launch()

    guard pipeError.fileHandleForReading.readDataToEndOfFile() == Data() else { throw MyError.runtimeError }
    let data = pipeOutput.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    
    return output
}

enum MyError: Error {
    case runtimeError
}
