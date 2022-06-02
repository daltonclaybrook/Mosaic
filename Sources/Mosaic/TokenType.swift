/// The various kinds of tokens that make up the Mosaic grammar
public enum TokenType: Equatable {
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
	case returnArrow // '->'

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
	case keywordConst
	case keywordVar
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
	static let tokenTypesFromKeyworkLexemes: [String: TokenType] = [
		"struct": .keywordStruct,
		"impl": .keywordImpl,
		"func": .keywordFunc,
		"const": .keywordConst,
		"var": .keywordVar,
		"if": .keywordIf,
		"else": .keywordElse,
		"each": .keywordEach,
		"in": .keywordIn,
		"while": .keywordWhile,
		"return": .keywordReturn,
		"break": .keywordBreak,
		"true": .keywordTrue,
		"false": .keywordFalse,
		"nil": .keywordNil
	]

	static let allKeywords: Set<TokenType> = Set(tokenTypesFromKeyworkLexemes.values)

	static func keyword(for lexeme: String) -> TokenType? {
		tokenTypesFromKeyworkLexemes[lexeme]
	}
}
