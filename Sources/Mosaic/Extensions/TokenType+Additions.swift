extension TokenType {
	var literalKind: Literal.Kind? {
		switch self {
		case .keywordNil:
			return .nil
		case .keywordTrue, .keywordFalse:
			return .boolean
		case .integerLiteral:
			return .integer
		case .fixedLiteral:
			return .fixed
		case .stringLiteral:
			return .string
		default:
			return nil
		}
	}
}
