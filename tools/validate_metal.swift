// Compiles every .metal file in ../metal at runtime (no Xcode needed).
// usage: swift tools/validate_metal.swift metal
import Metal
import Foundation
let dir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "metal"
guard let dev = MTLCreateSystemDefaultDevice() else { print("no Metal device"); exit(1) }
let fm = FileManager.default
let common = try! String(contentsOfFile: dir + "/Common.h", encoding: .utf8)
    .replacingOccurrences(of: "#pragma once", with: "")
var failed = 0
for f in try! fm.contentsOfDirectory(atPath: dir).sorted() where f.hasSuffix(".metal") {
    var src = try! String(contentsOfFile: dir + "/" + f, encoding: .utf8)
    src = src.replacingOccurrences(of: "#include \"Common.h\"", with: common)
    do {
        let lib = try dev.makeLibrary(source: src, options: nil)
        print("OK   \(f): \(lib.functionNames.sorted().joined(separator: ", "))")
    } catch { failed += 1; print("FAIL \(f):\n\(error)") }
}
exit(failed == 0 ? 0 : 1)
