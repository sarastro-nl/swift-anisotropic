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
let power = 9 // 512
let res = 2 << (power - 1)

try shell("convert \(file) -gravity center -extent \(min)x\(min) square.ppm")
try shell("convert -size \(res)x\(res) xc: \(file).ppm")

var yposition = 0
var yscale = res
for _ in 1...power {
    yscale /= 2
    var xposition = 0
    var xscale = res
    for _ in 1...power {
        xscale /= 2
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
