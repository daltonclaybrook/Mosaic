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

	// MARK: - Declarations

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

	func testStructWithFields() throws {
		let parser = Parser(lexer: lexer)
		let contents = """
struct FooBar {
	var foo: UInt8
	const bar: Bool
}
"""
		let sourceFile = try XCTUnwrap(parser.parse(fileContents: contents).get())
		let expected = SourceFile(
			declarations: [
				.structure(StructDeclaration(
					type: .init(nameIdentifier: .test(.identifier, "FooBar")),
					variables: [
						.init(
							mutability: .variable,
							nameIdentifier: .test(.identifier, "foo"),
							typeIdentifier: .init(nameIdentifier: .test(.identifier, "UInt8", true))
						),
						.init(
							mutability: .constant,
							nameIdentifier: .test(.identifier, "bar"),
							typeIdentifier: .init(nameIdentifier: .test(.identifier, "Bool", true))
						)
					]
				))
			],
			endOfFile: .test(.endOfFile)
		)
		XCTAssertEqual(sourceFile, expected)
	}

	func testSourceLevelFunctionDeclaration() throws {
		let parser = Parser(lexer: lexer)
		let contents = """
func doSomething(foo: UInt8, bar: Bool) -> Bool {
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
						),
						.init(
							name: .test(.identifier, "bar"),
							type: .init(nameIdentifier: .test(.identifier, "Bool"))
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

	func testImplDeclaration() throws {
		let parser = Parser(lexer: lexer)
		let contents = """
struct FooBar {}
impl FooBar {
	func doStuff() {}
}
"""
		let sourceFile = try XCTUnwrap(parser.parse(fileContents: contents).get())
		let expected = SourceFile(
			declarations: [
				.structure(StructDeclaration(
					type: .init(nameIdentifier: .test(.identifier, "FooBar")),
					variables: []
				)),
				.structImpl(ImplDeclaration(
					type: .init(nameIdentifier: .test(.identifier, "FooBar")),
					methods: [
						FuncDeclaration(
							nameIdentifier: .test(.identifier, "doStuff"),
							parameters: [],
							statements: []
						)
					]
				))
			],
			endOfFile: .test(.endOfFile)
		)
		XCTAssertEqual(sourceFile, expected)
	}

	// MARK: - Statements

	func testVariableDeclarationInFunction() throws {
		let parser = Parser(lexer: lexer)
		let contents = """
func doSomething() {
	var foo = 123
}
"""
		let sourceFile = try XCTUnwrap(parser.parse(fileContents: contents).get())
		let expected = sourceFileWithOneFunction(named: "doSomething", statements: [
			.variable(VariableDeclaration(
				mutability: .variable,
				nameIdentifier: .test(.identifier, "foo"),
				initialValue: .integerLiteral(.test(.integerLiteral, "123", true))
			))
		])
		XCTAssertEqual(sourceFile, expected)
	}

	func testEachLoop() throws {
		let parser = Parser(lexer: lexer)
		let contents = """
func doSomething() {
	each index in foo() {
		123
	}
}
"""
		let sourceFile = try XCTUnwrap(parser.parse(fileContents: contents).get())
		let expected = sourceFileWithOneFunction(named: "doSomething", statements: [
			.each(EachStatement(
				element: .test(.identifier, "index"),
				collection: .call(Call(
					callable: Getter(identifiers: [
						.init(token: .test(.identifier, "foo"))
					]),
					arguments: []
				)),
				body: [
					.expression(.integerLiteral(.test(.integerLiteral, "123", true)))
				]
			))
		])
		XCTAssertEqual(sourceFile, expected)
	}

	func testWhileLoop() throws {
		let parser = Parser(lexer: lexer)
		let contents = """
func doSomething() {
	while foo <= 10 {
		print(foo)
	}
}
"""
		let sourceFile = try XCTUnwrap(parser.parse(fileContents: contents).get())
		let expected = sourceFileWithOneFunction(named: "doSomething", statements: [
			.while(WhileStatement(
				condition: .binary(Binary(
					left: .getter(Getter(
						identifiers: [
							.init(token: .test(.identifier, "foo"))
						]
					)),
					right: .integerLiteral(.test(.integerLiteral, "10")),
					operator: .lessThanOrEqual
				)),
				body: [
					.expression(
						.call(Call(
							callable: .init(
								identifiers: [.init(token: .test(.identifier, "print"))]
							),
							arguments: [
								.getter(Getter(
									identifiers: [
										.init(token: .test(.identifier, "foo"))
									]
								))
							]
						))
					)
				]
			))
		])
		XCTAssertEqual(sourceFile, expected)
	}

	func testIfStatement() throws {
		let parser = Parser(lexer: lexer)
		let contents = """
func doSomething() {
	if true {
		foo = 12
	}
}
"""
		let sourceFile = try XCTUnwrap(parser.parse(fileContents: contents).get())
		let expected = sourceFileWithOneFunction(named: "doSomething", statements: [
			.if(IfStatement(
				condition: .boolLiteral(true),
				thenBranch: [
					.assignment(Setter(
						getter: Getter(identifiers: [
							.init(token: .test(.identifier, "foo"))
						]),
						value: .integerLiteral(.test(.integerLiteral, "12", true))
					))
				]
			))
		])
		XCTAssertEqual(sourceFile, expected)
	}

	func testIfElseStatement() throws {
		let parser = Parser(lexer: lexer)
		let contents = """
func doSomething() {
	if true {
		return 12
	} else {
		return 13
	}
}
"""
		let sourceFile = try XCTUnwrap(parser.parse(fileContents: contents).get())
		let expected = sourceFileWithOneFunction(named: "doSomething", statements: [
			.if(IfStatement(
				condition: .boolLiteral(true),
				thenBranch: [
					.return(ReturnStatement(
						value: .integerLiteral(.test(.integerLiteral, "12", true))
					))
				],
				elseBranch: [
					.return(ReturnStatement(
						value: .integerLiteral(.test(.integerLiteral, "13", true))
					))
				]
			))
		])
		XCTAssertEqual(sourceFile, expected)
	}

	func testBreakStatement() throws {
		let parser = Parser(lexer: lexer)
		let contents = """
func doSomething() {
	while true {
		break
	}
}
"""
		let sourceFile = try XCTUnwrap(parser.parse(fileContents: contents).get())
		let expected = sourceFileWithOneFunction(named: "doSomething", statements: [
			.while(WhileStatement(
				condition: .boolLiteral(true),
				body: [
					.break
				]
			))
		])
		XCTAssertEqual(sourceFile, expected)
	}

	func testBreakStatementThrowsErrorIfNotInLoop() throws {
		let parser = Parser(lexer: lexer)
		let contents = """
func doSomething() {
   break
}
"""
		let errors = try XCTUnwrap(parser.parse(fileContents: contents).failure()).map(\.value)
		XCTAssertEqual(errors, [
			.unexpectedToken(.keywordBreak, lexeme: "break", message: Optional("The 'break' keyword may only be used inside of a loop"))
		])
	}

	// MARK: - Errors

	func testFuncInStructDeclarationThrowsError() throws {
		let parser = Parser(lexer: lexer)
		let contents = """
struct FooBar {
	func doStuff() {}
}
"""
		let errors = try XCTUnwrap(parser.parse(fileContents: contents).failure()).map(\.value)
		XCTAssertEqual(errors, [
			.unexpectedToken(.keywordFunc, lexeme: "func", message: "Struct declarations may only contain variable declarations")
		])
	}

	func testVarInImplDeclarationThrowsError() throws {
		let parser = Parser(lexer: lexer)
		let contents = """
struct FooBar {}
impl FooBar {
	var testing: Int = 12
}
"""
		let errors = try XCTUnwrap(parser.parse(fileContents: contents).failure()).map(\.value)
		XCTAssertEqual(errors, [
			.unexpectedToken(.keywordVar, lexeme: "var", message: "Struct implementations (impls) may only contain function declarations")
		])
	}

	func testFuncDeclarationInFuncDeclarationThrowsError() throws {
		let parser = Parser(lexer: lexer)
		let contents = """
func doStuff() {
	func doMoreStuff() {
		print("This is a test")
	}
}
"""
		let errors = try XCTUnwrap(parser.parse(fileContents: contents).failure()).map(\.value)
		XCTAssertEqual(errors, [
			.unexpectedToken(Mosaic.TokenType.keywordFunc, lexeme: "func", message: nil)
		])
	}

	func testLiteralInRootThrowsError() throws {
		let parser = Parser(lexer: lexer)
		let contents = """
123
"""
		let errors = try XCTUnwrap(parser.parse(fileContents: contents).failure()).map(\.value)
		XCTAssertEqual(errors, [
			.unexpectedToken(.integerLiteral, lexeme: "123", message: "Token not allowed in the root of a source file")
		])
	}
}

/// Make a source file with one function with no arguments or return type that contains the provided statements
private func sourceFileWithOneFunction(named: String, statements: [Statement]) -> SourceFile {
	SourceFile(
		declarations: [
			.function(FuncDeclaration(
				nameIdentifier: .test(.identifier, named),
				parameters: [],
				statements: statements
			))
		],
		endOfFile: .test(.endOfFile)
	)
}

struct ResultError: Error {}

extension Result {
	func failure() throws -> Failure {
		switch self {
		case .success:
			throw ResultError()
		case .failure(let error):
			return error
		}
	}
}
