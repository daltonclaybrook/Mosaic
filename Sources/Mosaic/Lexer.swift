import Foundation

public struct LexerResults {
	public let tokens: [Token]
	public let errors: [Located<ParseError>]
}

public protocol LexerType {
	func scanAllTokens(fileURL: URL) throws -> LexerResults
	func scanAllTokens(fileContents: String) -> LexerResults
}

public final class Lexer: LexerType {
	private var scannedTokens: [Token] = []
	private var errors: [Located<ParseError>] = []

	private var currentLexemeLine = 0
	private var currentLexemeColumn = 0

	public init() {}

	/// Load a Mosaic source file from the provided `fileURL`, scan it, and return a list of tokens
	public func scanAllTokens(fileURL: URL) throws -> LexerResults {
		let fileContents = try String(contentsOf: fileURL)
		return scanAllTokens(fileContents: fileContents)
	}

	/// Scan the provided contents of a Mosaic source file and return a list of tokens
	public func scanAllTokens(fileContents: String) -> LexerResults {
		var cursor = Cursor(string: fileContents)
		scannedTokens = []
		errors = []

		while !cursor.isAtEnd {
			startNewLexeme(cursor: cursor)
			scanNextToken(cursor: &cursor)
		}

		// update numbers to end-of-file position
		startNewLexeme(cursor: cursor)
		makeToken(type: .endOfFile, lexeme: "")
		return LexerResults(tokens: scannedTokens, errors: errors)
	}

	// MARK: - Private helpers

	private func startNewLexeme(cursor: Cursor) {
		currentLexemeLine = cursor.currentLine
		currentLexemeColumn = cursor.currentColumn
	}

	/// Convenience function for making a token using the current line and column
	private func makeToken<S>(type: TokenType, lexeme: S) where S: CustomStringConvertible {
		scannedTokens.append(
			Token(
				type: type,
				line: currentLexemeLine,
				column: currentLexemeColumn,
				lexeme: lexeme.description
			)
		)
	}

	/// Convenience function for generating an error at the current scan location
	private func emitError(_ error: ParseError) {
		errors.append(
			Located(
				value: error,
				line: currentLexemeLine,
				column: currentLexemeColumn
			)
		)
	}

	private func scanNextToken(cursor: inout Cursor) {
		let next = cursor.advance()
		switch next {
		case ".":
			makeToken(type: .dot, lexeme: next)
		case ",":
			makeToken(type: .comma, lexeme: next)
		case "!":
			makeToken(type: .bang, lexeme: next)
		case "*":
			makeToken(type: .star, lexeme: next)
		case "%":
			makeToken(type: .percent, lexeme: next)
		case "+":
			makeToken(type: .plus, lexeme: next)
		case "-" where cursor.match(next: ">"):
			makeToken(type: .returnArrow, lexeme: "->")
		case "-":
			makeToken(type: .minus, lexeme: next)
		case "=":
			makeToken(type: .equal, lexeme: next)
		case "&":
			makeToken(type: .ampersand, lexeme: next)
		case "|":
			makeToken(type: .pipe, lexeme: next)
		case ":":
			makeToken(type: .colon, lexeme: next)
		case "'":
			makeToken(type: .singleQuote, lexeme: next)
		case "(":
			makeToken(type: .leadingParen, lexeme: next)
		case ")":
			makeToken(type: .trailingParen, lexeme: next)
		case "{":
			makeToken(type: .leadingBrace, lexeme: next)
		case "}":
			makeToken(type: .trailingBrace, lexeme: next)
		case "[":
			makeToken(type: .leadingBracket, lexeme: next)
		case "]":
			makeToken(type: .trailingBracket, lexeme: next)
		case "<":
			makeToken(type: .lessThan, lexeme: next)
		case ">":
			makeToken(type: .greaterThan, lexeme: next)
		case "\"":
			scanStringLiteral(cursor: &cursor)
		case "/" where cursor.match(next: "/"):
			scanCommentLine(cursor: &cursor)
		case "/":
			makeToken(type: .slash, lexeme: next)
		default:
			if next.isNewline {
				makeToken(type: .newline, lexeme: next)
			} else if next.isNumber {
				scanNumberLiteral(cursor: &cursor)
			} else if next.isIdentifierHead {
				scanIdentifierOrKeyword(cursor: &cursor)
			} else if next.isWhitespace {
				// Ignore whitespace (unless it's a newline, which is handled above)
				break
			} else {
				emitError(.unrecognizedCharacter(next))
			}
		}
	}

	func scanStringLiteral(cursor: inout Cursor) {
		// Start with the first quote since we've already scanned it
		var lexeme = String(cursor.previous)
		while !cursor.isAtEnd {
			let next = cursor.advance()
			guard !next.isNewline else {
				emitError(.unterminatedString(lexeme))
				return
			}

			lexeme.append(next)
			if next == "\"" {
				// String terminated with a closing quote
				makeToken(type: .stringLiteral, lexeme: lexeme)
				return
			}
		}
		// Should have returned from inside the loop upon encountering a closing quote
		emitError(.unterminatedString(lexeme))
	}

	func scanCommentLine(cursor: inout Cursor) {
		while !cursor.isAtEnd && !cursor.match(\.isNewline) {
			cursor.advance()
		}
	}

	func scanNumberLiteral(cursor: inout Cursor) {
		// The first digit has already been scanned
		var lexeme = String(cursor.previous)
		var scannedDot = false
		while !cursor.isAtEnd {
			let next = cursor.peek()
			if next == "." {
				lexeme.append(cursor.advance())
				if scannedDot {
					// Already scanned a dot in this number literal
					emitError(.invalidNumberLiteral(lexeme))
					return
				} else if !cursor.peek().isNumber {
					// The character following a dot must be a number
					emitError(.invalidNumberLiteral(lexeme))
					return
				} else {
					scannedDot = true
					lexeme.append(cursor.advance())
				}
			} else if next.isNumber {
				lexeme.append(cursor.advance())
			} else {
				// Reached the end of the number. Break out of loop to make token.
				break
			}
		}

		let tokenType: TokenType = scannedDot ? .fixedLiteral : .integerLiteral
		makeToken(type: tokenType, lexeme: lexeme)
	}

	func scanIdentifierOrKeyword(cursor: inout Cursor) {
		// First character of identifier has already been scanned
		var lexeme = String(cursor.previous)
		while !cursor.isAtEnd {
			let next = cursor.peek()
			if next.isIdentifierChar {
				lexeme.append(cursor.advance())
			} else {
				break
			}
		}

		if let keyword = TokenType.keyword(for: lexeme) {
			makeToken(type: keyword, lexeme: lexeme)
		} else {
			makeToken(type: .identifier, lexeme: lexeme)
		}
	}
}
