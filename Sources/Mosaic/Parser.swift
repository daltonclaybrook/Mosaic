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
		case .keywordVar, .keywordConst:
		}
	}

	private func parseStructureDeclaration() throws -> StructDeclaration {
		try consume(type: .keywordStruct, message: "Expected 'struct' keyword")
		let type = try parseTypeDeclaration()
		try consume(type: .leadingBrace, message: "Expected '{' after struct type")
		var variables: [VariableDeclaration] = []
		while match(type: .trailingBrace) == false {
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
	}

	private func parseVariableMutability() throws -> VariableDeclaration.Mutability {
		if match(type: .keywordVar) {
			return .variable
		} else {
			try consume(type: .keywordConst, message: "Expected 'const' or 'var' keyword in variable declaration")
			return .constant
		}
	}

	private func parseTypeDeclaration() throws -> TypeDeclaration {
		let name = try consume(type: .identifier, message: "Expected name identifier of type")
		var generics: [GenericDeclaration] = []
		if match(type: .lessThan) {
			// Must contain at least one generic type after less-than symbol
			try generics.append(parseSingleGenericDeclaration())
			while match(type: .comma) {
				try generics.append(parseSingleGenericDeclaration())
			}
			try consume(type: .greaterThan, message: "Expected '>' symbol after generics list")
		}

		return TypeDeclaration(nameIdentifier: name, generics: generics)
	}

	private func parseTypeIdentifier() throws -> TypeIdentifier {
		let name = try consume(type: .identifier, message: "Expected name identifier of type")
		var generics: [GenericIdentifier] = []
		if match(type: .lessThan) {
			try generics.append(parseSingleGenericIdentifier())
			while match(type: .greaterThan) == false {
				try generics.append(parseSingleGenericIdentifier())
			}
		}
		return TypeIdentifier(nameIdentifier: name, generics: generics)
	}

	private func parseSingleGenericDeclaration() throws -> GenericDeclaration {
		if match(type: .singleQuote) {
			// This is a value generic
			let name = try consume(type: .identifier, message: "Expected name of generic value")
			try consume(type: .colon, message: "Expected ':' after generic value name")
			let type = try parseTypeIdentifier()
			return .value(name: name, type: type)
		} else {
			// This is a type generic
			let name = try consume(type: .identifier, message: "Expected name of generic type")
			return .type(name: name)
		}
	}

	private func parseSingleGenericIdentifier() throws -> GenericIdentifier {
		if let literalKind = currentToken.type.literalKind {
			let token = try consume()
			return .value(Literal(token: token, kind: literalKind))
		} else {
			let type = try parseTypeIdentifier()
			return .type(type)
		}
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

	@discardableResult
	private func consume(type: TokenType, message: String) throws -> Token {
		guard match(type: type) else {
			throw ParseError.unexpectedToken(currentToken.type, lexeme: currentToken.lexeme, message: message)
		}
		return previousToken
	}

	@discardableResult
	private func consume() throws -> Token {
		guard !isAtEnd else {
			throw ParseError.unexpectedEndOfFile
		}
		currentTokenIndex += 1
		return previousToken
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
