@testable import Mosaic
import XCTest

final class LexerTests: XCTestCase {
	private var subject: Lexer!

	override func setUp() {
		super.setUp()
		subject = Lexer()
	}

	func testEmptyStringIsScanned() {
		let contents = ""
		let results = subject.scanAllTokens(fileContents: contents)
		let tokenTypes = results.tokens.map(\.type)
		XCTAssertEqual(tokenTypes, [.endOfFile])
		XCTAssertEqual(results.errors, [])
	}

	func testSymbolsAreScanned() {
		let contents = ".,!*/%+-=&|:'(){}[]<>"
		let results = subject.scanAllTokens(fileContents: contents)
		let tokenTypes = results.tokens.map(\.type)
		XCTAssertEqual(tokenTypes, [
			.dot, .comma, .bang, .star, .slash, .percent,
			.plus, .minus, .equal, .ampersand, .pipe, .colon,
			.singleQuote, .leadingParen, .trailingParen,
			.leadingBrace, .trailingBrace, .leadingBracket,
			.trailingBracket, .lessThan, .greaterThan, .endOfFile
		])
		XCTAssertEqual(results.errors, [])
	}

	func testInvalidSymbolEmitsError() {
		let contents = "$"
		let results = subject.scanAllTokens(fileContents: contents)
		let tokenTypes = results.tokens.map(\.type)
		let errors = results.errors.map(\.value)
		XCTAssertEqual(tokenTypes, [.endOfFile])
		XCTAssertEqual(errors, [.unrecognizedCharacter("$")])
	}

	func testStringLiteralIsScanned() {
		let contents = "\"Hello, my name is \\(person.name)\""
		let results = subject.scanAllTokens(fileContents: contents)
		let tokenTypes = results.tokens.map(\.type)
		XCTAssertEqual(tokenTypes, [.stringLiteral, .endOfFile])
		XCTAssertEqual(results.tokens[0].lexeme, contents)
		XCTAssertEqual(results.errors, [])
	}

	func testIntegerLiteralIsScanned() {
		let contents = "123"
		let results = subject.scanAllTokens(fileContents: contents)
		let tokenTypes = results.tokens.map(\.type)
		XCTAssertEqual(tokenTypes, [.integerLiteral, .endOfFile])
		XCTAssertEqual(results.tokens[0].lexeme, contents)
		XCTAssertEqual(results.errors, [])
	}

	func testFixedLiteralIsScanned() {
		let contents = "12.3"
		let results = subject.scanAllTokens(fileContents: contents)
		let tokenTypes = results.tokens.map(\.type)
		XCTAssertEqual(tokenTypes, [.fixedLiteral, .endOfFile])
		XCTAssertEqual(results.tokens[0].lexeme, contents)
		XCTAssertEqual(results.errors, [])
	}

	func testMultipleNumbersAreScanned() {
		let contents = "12 34 5.6 7"
		let results = subject.scanAllTokens(fileContents: contents)
		let tokenTypes = results.tokens.map(\.type)
		let lexemes = results.tokens.map(\.lexeme)
		XCTAssertEqual(tokenTypes, [.integerLiteral, .integerLiteral, .fixedLiteral, .integerLiteral, .endOfFile])
		XCTAssertEqual(lexemes, ["12", "34", "5.6", "7", ""])
		XCTAssertEqual(results.errors, [])
	}

	func testInvalidNumberEmitsError() {
		let contents = "12."
		let results = subject.scanAllTokens(fileContents: contents)
		let tokenTypes = results.tokens.map(\.type)
		let errors = results.errors.map(\.value)
		XCTAssertEqual(tokenTypes, [.endOfFile])
		XCTAssertEqual(errors, [.invalidNumberLiteral("12.")])
	}
}
