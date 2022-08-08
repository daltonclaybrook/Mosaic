@testable import Mosaic

extension Token {
	/// Convenience for creating simple Tokens for testing that only contain useful information
	/// about the token type and lexeme
	static func test(_ type: TokenType, _ lexeme: String = "", _ isTerminatedWithNewline: Bool = false) -> Token {
		Token(type: type, line: 0, column: 0, lexeme: lexeme, isTerminatedWithNewline: isTerminatedWithNewline)
	}
}
