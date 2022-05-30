/// The various kinds of tokens that make up the Mosaic grammar
enum TokenType {
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
