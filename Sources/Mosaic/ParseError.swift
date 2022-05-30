public enum ParseError: Error, Equatable {
	case unrecognizedCharacter(Character)
	case unterminatedString(String)
	case invalidNumberLiteral(String)
	case invalidIdentifier(String)
}
