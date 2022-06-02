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

	}

	// MARK: - Private helpers

	private var isAtEnd: Bool {
		tokens[currentTokenIndex].type == .endOfFile
	}

	private var currentToken: Token {
		precondition(currentTokenIndex < tokens.count, "Token index out of bounds")
		return tokens[currentTokenIndex]
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
