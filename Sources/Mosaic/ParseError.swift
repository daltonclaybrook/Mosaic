public enum ParseError: Error, Equatable {
	/// Encountered a character in the lexer that is not part of the Mosaic grammar
	case unrecognizedCharacter(Character)
	/// A string literal does not contain a terminating quote
	case unterminatedString(String)
	/// A number literal is invalid
	case invalidNumberLiteral(String)
	/// The parser expected a token that was not found
	case unexpectedToken(TokenType, lexeme: String, message: String)
	/// The parser encountered the end of file unexpectedly
	case unexpectedEndOfFile
	/// The parser encountered an unexpected expression
	case invalidAssignmentTarget(message: String)
}
