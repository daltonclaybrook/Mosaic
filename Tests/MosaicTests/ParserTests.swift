@testable import Mosaic
import XCTest

final class ParserTests: XCTestCase {
	private var lexer: LexerType!

	override func setUp() {
		super.setUp()
		lexer = Lexer(overrides: TokenOverrides(line: 0, column: 0))
	}

	func testEmptyFile() throws {
		let parser = Parser(lexer: lexer)
		let sourceFile = try XCTUnwrap(parser.parse(fileContents: "").get())
		let expected = SourceFile(declarations: [], endOfFile: .test(.endOfFile))
		XCTAssertEqual(sourceFile, expected)
	}

	func testEmptyStructDeclaration() throws {
		let parser = Parser(lexer: lexer)
		let contents = """
struct FooBar {
	// This is an empty struct
}
"""
		let sourceFile = try XCTUnwrap(parser.parse(fileContents: contents).get())
		let expected = SourceFile(
			declarations: [
				.structure(StructDeclaration(
					type: .init(nameIdentifier: .test(.identifier, "FooBar")),
					variables: []
				))
			],
			endOfFile: .test(.endOfFile)
		)
		XCTAssertEqual(sourceFile, expected)
	}

	func testSourceLevelFunctionDeclaration() throws {
		let parser = Parser(lexer: lexer)
		let contents = """
func doSomething(foo: UInt8) -> Bool {
	return true
}
"""
		let sourceFile = try XCTUnwrap(parser.parse(fileContents: contents).get())
		let expected = SourceFile(
			declarations: [
				.function(FuncDeclaration(
					nameIdentifier: .test(.identifier, "doSomething"),
					parameters: [
						.init(
							name: .test(.identifier, "foo"),
							type: .init(nameIdentifier: .test(.identifier, "UInt8"))
						)
					],
					returnType: .init(nameIdentifier: .test(.identifier, "Bool")),
					statements: [
						.return(.init(value: .boolLiteral(true)))
					]
				))
			],
			endOfFile: .test(.endOfFile)
		)
		XCTAssertEqual(sourceFile, expected)
	}

	func testSourceLevelVariableDeclarations() throws {
		let parser = Parser(lexer: lexer)
		let contents = """
var foo = 123
const bar: String = "abc"
var fizz: UInt8
"""
		let sourceFile = try XCTUnwrap(parser.parse(fileContents: contents).get())
		let expected = SourceFile(
			declarations: [
				.variable(VariableDeclaration(
					mutability: .variable,
					nameIdentifier: .test(.identifier, "foo"),
					initialValue: .integerLiteral(.test(.integerLiteral, "123", true))
				)),
				.variable(VariableDeclaration(
					mutability: .constant,
					nameIdentifier: .test(.identifier, "bar"),
					typeIdentifier: .init(nameIdentifier: .test(.identifier, "String")),
					initialValue: .stringLiteral(.test(.stringLiteral, "\"abc\"", true))
				)),
				.variable(VariableDeclaration(
					mutability: .variable,
					nameIdentifier: .test(.identifier, "fizz"),
					typeIdentifier: .init(nameIdentifier: .test(.identifier, "UInt8"))
				))
			],
			endOfFile: .test(.endOfFile)
		)
		XCTAssertEqual(sourceFile, expected)
	}
}