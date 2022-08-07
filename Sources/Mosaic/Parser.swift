import Foundation

public final class Parser {
	private let lexer: LexerType
	private var currentTokenIndex: Int = 0
	private var tokens: [Token] = []
	private var errors: [Located<ParseError>] = []

	public init(lexer: LexerType = Lexer()) {
		self.lexer = lexer
	}

	/// Parse the Mosaic source file at the provided file URL and return the parsed AST representation, or a list of errors on failure
	public func parseFile(at url: URL) throws -> Result<SourceFile, [Located<ParseError>]> {
		let fileContents = try String(contentsOf: url)
		return parse(fileContents: fileContents)
	}

	/// Parse the provided Mosaic source file contents and return the parsed AST representation, or a list of errors on failure
	public func parse(fileContents: String) -> Result<SourceFile, [Located<ParseError>]> {
		let lexerResults = lexer.scanAllTokens(fileContents: fileContents)
		self.tokens = lexerResults.tokens
		self.errors = lexerResults.errors
		currentTokenIndex = 0

		precondition(!tokens.isEmpty, "The returned tokens array should never be empty")
		precondition(tokens.last?.type == .endOfFile, "The returned tokens array must be terminated by an `.endOfFile` token")
		return parseSourceFile()
	}

	// MARK: - Parser functions

	private func parseSourceFile() -> Result<SourceFile, [Located<ParseError>]> {
		var declarations: [InSourceDeclaration] = []
		while !isAtEnd {
			do {
				declarations.append(try parseInSourceDeclaration())
			} catch let error as ParseError {
				emitError(error)
				synchronize()
			} catch let error {
				assertionFailure("Unhandled error: \(error.localizedDescription)")
				synchronize()
			}
		}

		if errors.isEmpty {
			return .success(SourceFile(declarations: declarations, endOfFile: currentToken))
		} else {
			return .failure(errors)
		}
	}

	private func parseInSourceDeclaration() throws -> InSourceDeclaration {
		switch currentToken.type {
		case .keywordStruct:
			return try .structure(parseStructureDeclaration())
		case .keywordFunc:
			return try .function(parseFunctionDeclaration())
		case .keywordVar, .keywordConst:
			return try .variable(parseVariableDeclaration())
		default:
			throw ParseError.unexpectedToken(currentToken.type, lexeme: currentToken.lexeme, message: "Token not allowed in the root of a source file")
		}
	}

	private func parseStructureDeclaration() throws -> StructDeclaration {
		try consume(type: .keywordStruct, message: "Expected 'struct' keyword")
		let type = try parseTypeIdentifier()
		try consume(type: .leadingBrace, message: "Expected '{' after struct type")
		var variables: [VariableDeclaration] = []
		while !isAtEnd && match(type: .trailingBrace) == false {
			try variables.append(parseVariableDeclaration())
		}
		return StructDeclaration(type: type, variables: variables)
	}

	private func parseVariableDeclaration() throws -> VariableDeclaration {
		let mutability = try parseVariableMutability()
		let name = try consume(type: .identifier, message: "Expected variable name identifier")

		var type: TypeIdentifier?
		if match(type: .colon) {
			type = try parseTypeIdentifier()
		}

		var initialValue: Expression?
		if match(type: .equal) {
			initialValue = try parseExpression()
		}

		try verifyStatementEnd()

		return VariableDeclaration(
			mutability: mutability,
			nameIdentifier: name,
			typeIdentifier: type,
			initialValue: initialValue
		)
	}

	private func parseVariableMutability() throws -> VariableDeclaration.Mutability {
		if match(type: .keywordVar) {
			return .variable
		} else if match(type: .keywordConst) {
			return .constant
		} else {
			throw ParseError.unexpectedToken(currentToken.type, lexeme: currentToken.lexeme, message: "Expected 'const' or 'var' keyword in variable declaration")
		}
	}

	private func parseTypeIdentifier() throws -> TypeIdentifier {
		let name = try consume(type: .identifier, message: "Expected name identifier of type")
		return TypeIdentifier(nameIdentifier: name)
	}

	private func parseFunctionDeclaration() throws -> FuncDeclaration {
		try consume(type: .keywordFunc, message: "Expected 'func' keyword")
		let name = try consume(type: .identifier, message: "Expected function name identifier after 'func' keyword")
		try consume(type: .leadingParen, message: "Expected '(' after function name")

		var parameters: [FuncDeclaration.Parameter] = []
		if match(type: .trailingParen) == false {
			try parameters.append(parseFunctionParameter())
			while match(type: .comma) {
				try parameters.append(parseFunctionParameter())
			}
			try consume(type: .trailingParen, message: "Expected ')' after parameter list")
		}

		var returnType: TypeIdentifier?
		if match(type: .returnArrow) {
			returnType = try parseTypeIdentifier()
		}

		let statements = try parseStatementsBlock()

		return FuncDeclaration(
			nameIdentifier: name,
			parameters: parameters,
			returnType: returnType,
			statements: statements
		)
	}

	private func parseFunctionParameter() throws -> FuncDeclaration.Parameter {
		let name = try consume(type: .identifier, message: "Expected name identifier of function parameter")
		try consume(type: .colon, message: "Expected ':' after parameter name")
		let type = try parseTypeIdentifier()
		return FuncDeclaration.Parameter(name: name, type: type)
	}

	private func parseStatementsBlock() throws -> [Statement] {
		try consume(type: .leadingBrace, message: "Expected '{' token")
		var statements: [Statement] = []
		while !isAtEnd && willMatch(.trailingBrace) == false {
			try statements.append(parseStatement())
		}
		try consume(type: .trailingBrace, message: "Expected '}' to close block")
		return statements
	}

	private func parseStatement() throws -> Statement {
		switch currentToken.type {
		case .keywordVar, .keywordConst:
			return try .variable(parseVariableDeclaration())
		case .keywordEach:
			return try .each(parseEachStatement())
		case .keywordWhile:
			return try .`while`(parseWhileStatement())
		case .keywordIf:
			return try .`if`(parseIfStatement())
		case .keywordReturn:
			return try .return(parseReturnStatement())
		case .keywordBreak:
			return try .break(parseBreakStatement())
		default:
			return try parseAssignmentOrExpressionStatement()
		}
	}

	private func parseEachStatement() throws -> EachStatement {
		try consume(type: .keywordEach, message: "Expected 'each' keyword")
		let element = try consume(type: .identifier, message: "Expected element name identifier")
		try consume(type: .keywordIn, message: "Expected 'in' keyword after element name")
		let collection = try parseExpression()
		let statements = try parseStatementsBlock()
		return EachStatement(
			element: element,
			collection: collection,
			body: statements
		)
	}

	private func parseWhileStatement() throws -> WhileStatement {
		try consume(type: .keywordWhile, message: "Expected 'while' keyword")
		let condition = try parseExpression()
		let statements = try parseStatementsBlock()
		return WhileStatement(
			condition: condition,
			body: statements
		)
	}

	private func parseIfStatement() throws -> IfStatement {
		try consume(type: .keywordIf, message: "Expected 'if' keyword")
		let condition = try parseExpression()
		let thenStatements = try parseStatementsBlock()

		var elseStatements: [Statement]?
		if match(type: .keywordElse) {
			elseStatements = try parseStatementsBlock()
		}

		return IfStatement(
			condition: condition,
			thenBranch: thenStatements,
			elseBranch: elseStatements
		)
	}

	private func parseReturnStatement() throws -> ReturnStatement {
		let token = try consume(type: .keywordReturn, message: "Expected 'return' keyword")
		let value = token.isTerminatedWithNewline ? nil : try parseExpression()
		try verifyStatementEnd()
		return ReturnStatement(
			value: value
		)
	}

	private func parseBreakStatement() throws -> BreakStatement {
		try consume(type: .keywordBreak, message: "Expected 'break' keyword")
		try verifyStatementEnd()
		return BreakStatement()
	}

	private func parseAssignmentOrExpressionStatement() throws -> Statement {
		let expression = try parseExpression()
		if match(type: .equal) {
			guard let getter = expression as? Getter else {
				throw ParseError.invalidAssignmentTarget(message: "The expression that preceded the assignment operator was not a valid assignment target.")
			}
			let value = try parseExpression()
			try verifyStatementEnd()
			return .assignment(Setter(getter: getter, value: value))
		} else {
			try verifyStatementEnd()
			return .expression(expression)
		}
	}

	private func parseExpression() throws -> Expression {
		try parseLogicOr()
	}

	private func parseLogicOr() throws -> Expression {
		fatalError("unimplemented")
	}

	private func parseLogicAnd() throws -> Expression {
		fatalError("unimplemented")
	}

	private func parseBitwiseOr() throws -> Expression {
		fatalError("unimplemented")
	}

	private func parseBitwiseXor() throws -> Expression {
		fatalError("unimplemented")
	}

	private func parseBitwiseAnd() throws -> Expression {
		fatalError("unimplemented")
	}

	private func parseEquality() throws -> Expression {
		fatalError("unimplemented")
	}

	private func parseComparison() throws -> Expression {
		fatalError("unimplemented")
	}

	private func parseBitwiseShift() throws -> Expression {
		fatalError("unimplemented")
	}

	private func parseBinaryTerm() throws -> Expression {
		fatalError("unimplemented")
	}

	private func parseBinaryFactor() throws -> Expression {
		fatalError("unimplemented")
	}

	private func parseUnary() throws -> Expression {
		fatalError("unimplemented")
	}

	private func parseCall() throws -> Expression {
		fatalError("unimplemented")
	}

	private func parsePrimary() throws -> Expression {
		fatalError("unimplemented")
	}

	private func parseGetter() throws -> Expression {
		fatalError("unimplemented")
	}

	// MARK: - Private helpers

	private var isAtEnd: Bool {
		tokens[currentTokenIndex].type == .endOfFile
	}

	private var currentToken: Token {
		precondition(currentTokenIndex < tokens.count, "Token index out of bounds")
		return tokens[currentTokenIndex]
	}

	private var previousToken: Token {
		precondition(currentTokenIndex > 0, "Attempt to access token previous to the first one")
		return tokens[currentTokenIndex - 1]
	}

	@discardableResult
	private func match(type: TokenType) -> Bool {
		guard !isAtEnd else { return false }
		if tokens[currentTokenIndex].type == type {
			currentTokenIndex += 1
			return true
		} else {
			return false
		}
	}

	/// Returns true if the next several tokens will match the provided sequence of token types. This function
	/// does not advance the current token index.
	private func willMatch(_ types: TokenType...) -> Bool {
		for (type, offset) in zip(types, 0...) {
			let index = currentTokenIndex + offset
			guard index < tokens.count else { return false }
			guard tokens[index].type == type else { return false }
		}
		return true
	}

	@discardableResult
	private func consume(type: TokenType, message: String) throws -> Token {
		guard match(type: type) else {
			throw ParseError.unexpectedToken(currentToken.type, lexeme: currentToken.lexeme, message: message)
		}
		return previousToken
	}

	@discardableResult
	private func consumeNext() throws -> Token {
		guard !isAtEnd else {
			throw ParseError.unexpectedEndOfFile
		}
		currentTokenIndex += 1
		return previousToken
	}

	/// Verifies that the previous/current tokens are suitable to terminate a statement or variable
	/// declaration. This function does not consume any tokens.
	private func verifyStatementEnd() throws {
		if previousToken.isTerminatedWithNewline {
			// Newlines are an acceptable terminator for a statement
			return
		}

		switch currentToken.type {
		case .trailingBrace, .endOfFile:
			// These tokens are acceptable
			break
		default:
			throw ParseError.unexpectedToken(currentToken.type, lexeme: currentToken.lexeme, message: "Statement is unterminated. Statements are terminated with a newline character, or by a scope ending")
		}
	}

	private func emitError(_ error: ParseError) {
		errors.append(
			Located(value: error, line: currentToken.line, column: currentToken.column)
		)
	}

	private func synchronize() {
		while !isAtEnd {
			switch currentToken.type {
			case .keywordStruct, .keywordImpl, .keywordFunc:
				return
			default:
				currentTokenIndex += 1
			}
		}
	}
}
