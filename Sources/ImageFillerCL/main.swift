import Foundation

do {
    try CommandLineTool().run()
} catch {
    print("Whoops! An error occurred: \(error)")
}
