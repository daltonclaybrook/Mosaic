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
		let contents = ".,!*/%+-=&|:'(){}[]<>->"
		let results = subject.scanAllTokens(fileContents: contents)
		let tokenTypes = results.tokens.map(\.type)
		XCTAssertEqual(tokenTypes, [
			.dot, .comma, .bang, .star, .slash, .percent,
			.plus, .minus, .equal, .ampersand, .pipe, .colon,
			.singleQuote, .leadingParen, .trailingParen,
			.leadingBrace, .trailingBrace, .leadingBracket,
			.trailingBracket, .lessThan, .greaterThan, .returnArrow,
			.endOfFile
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

	func testUnterminatedStringLiteralEmitsError() {
		let contents = "\"Hello, world!"
		let results = subject.scanAllTokens(fileContents: contents)
		let tokenTypes = results.tokens.map(\.type)
		let errors = results.errors.map(\.value)
		XCTAssertEqual(tokenTypes, [.endOfFile])
		XCTAssertEqual(errors, [.unterminatedString(contents)])
	}

	func testStringLiteralWithNewlineEmitsErrors() {
		let contents = "\"Hello\nWorld!\""
		let results = subject.scanAllTokens(fileContents: contents)
		let tokenTypes = results.tokens.map(\.type)
		let errors = results.errors.map(\.value)
		XCTAssertEqual(tokenTypes, [.identifier, .bang, .endOfFile])
		XCTAssertEqual(errors, [.unterminatedString("\"Hello"), .unterminatedString("\"")])
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

	func testInvalidNumberEmitsError2() {
		let contents = "12.34.5"
		let results = subject.scanAllTokens(fileContents: contents)
		let tokenTypes = results.tokens.map(\.type)
		let errors = results.errors.map(\.value)
		XCTAssertEqual(tokenTypes, [.integerLiteral, .endOfFile])
		XCTAssertEqual(errors, [.invalidNumberLiteral("12.34.")])
	}

	func testKeywordsAreScanned() {
		let contents = "struct impl func const var if else each in while return break true false nil self"
		let results = subject.scanAllTokens(fileContents: contents)
		let tokenTypes = results.tokens.map(\.type)
		let expectedKeywords: [TokenType] = [
			.keywordStruct, .keywordImpl, .keywordFunc, .keywordConst,
			.keywordVar, .keywordIf, .keywordElse, .keywordEach, .keywordIn,
			.keywordWhile, .keywordReturn, .keywordBreak, .keywordTrue,
			.keywordFalse, .keywordNil, .keywordSelf
		]
		XCTAssertEqual(tokenTypes, expectedKeywords + [.endOfFile])
		// Ensure we've tested all keywords
		let missingKeywords = TokenType.allKeywords.subtracting(expectedKeywords)
		XCTAssertEqual(missingKeywords, [])
		XCTAssertEqual(results.errors, [])
	}

	func testIdentifierIsScanned() {
		let contents = "FooBar"
		let results = subject.scanAllTokens(fileContents: contents)
		let tokenTypes = results.tokens.map(\.type)
		XCTAssertEqual(tokenTypes, [.identifier, .endOfFile])
		XCTAssertEqual(results.errors, [])
	}

	func testCommentsAreIgnored() {
		let contents = """
		// This is a comment line
		var foo = "abc"
		// This is another
		foo+2
		"""
		let results = subject.scanAllTokens(fileContents: contents)
		let tokenTypes = results.tokens.map(\.type)
		XCTAssertEqual(tokenTypes, [
			.keywordVar, .identifier, .equal, .stringLiteral,
			.identifier, .plus, .integerLiteral, .endOfFile
		])
	}

	func testTokenLineAndColumnNumbersAreCorrect() {
		let contents = """
		struct FooBar<T> {
			value: T
		}

		// This is a comment
		var foo = FooBar(value: 17)
		const bar = foo.value + 12
		"""
		let results = subject.scanAllTokens(fileContents: contents)
		let lines = results.tokens.map(\.line)
		let columns = results.tokens.map(\.column)
		XCTAssertEqual(lines, [
			1, 1, 1, 1, 1, 1,
			2, 2, 2,
			3,
			6, 6, 6, 6, 6, 6, 6, 6, 6,
			7, 7, 7, 7, 7, 7, 7, 7,
			7 // EOF
		])
		XCTAssertEqual(columns, [
			1, 8, 14, 15, 16, 18,
			2, 7, 9,
			1,
			1, 5, 9, 11, 17, 18, 23, 25, 27,
			1, 7, 11, 13, 16, 17, 23, 25,
			27 // EOF
		])
		XCTAssertEqual(results.errors, [])
	}
}
