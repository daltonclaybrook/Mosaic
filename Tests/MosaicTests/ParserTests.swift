@testable import Mosaic
import XCTest

final class ParserTests: XCTestCase {
	func testEmptyFile() throws {
		let parser = Parser()
		let sourceFile = try XCTUnwrap(parser.parse(fileContents: "").get())

	}
}
