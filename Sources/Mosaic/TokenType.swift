/// The various kinds of tokens that make up the Mosaic grammar
public enum TokenType {
	// Symbols
	case dot // '.'
	case comma // ','
	case bang // '!'
	case star // '*'
	case slash // '/'
	case percent // '%'
	case plus // '+'
	case minus // '-'
	case equal // '='
	case ampersand // '&'
	case pipe // '|'
	case colon // ':'
	case singleQuote // '
	case leadingParen // '('
	case trailingParen // ')'
	case leadingBrace // '{'
	case trailingBrace // '}'
	case leadingBracket // '['
	case trailingBracket // ']'
	case lessThan // '<'
	case greaterThan // '>'

	// Literals
	case stringLiteral
	case integerLiteral
	case fixedLiteral
	case arrayLiteral

	// Special
	case identifier
	case endOfFile
	case newline

	// Keywords
	case keywordStruct
	case keywordImpl
	case keywordFunc
	case keywordIf
	case keywordElse
	case keywordEach
	case keywordIn
	case keywordWhile
	case keywordReturn
	case keywordBreak
	case keywordTrue
	case keywordFalse
	case keywordNil
}

extension TokenType {
	static func keyword(for lexeme: String) -> TokenType? {
		switch lexeme {
		case "struct":
			return .keywordStruct
		case "impl":
			return .keywordImpl
		case "func":
			return .keywordFunc
		case "if":
			return .keywordIf
		case "else":
			return .keywordElse
		case "each":
			return .keywordEach
		case "in":
			return .keywordIn
		case "while":
			return .keywordWhile
		case "return":
			return .keywordReturn
		case "break":
			return .keywordBreak
		case "true":
			return .keywordTrue
		case "false":
			return .keywordFalse
		case "nil":
			return .keywordNil
		default:
			return nil
		}
	}
}
