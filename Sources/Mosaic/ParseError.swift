public enum ParseError: Error {
	case unrecognizedCharacter(Character)
	case unterminatedString(String)
	case invalidNumberLiteral(String)
	case invalidIdentifier(String)
}
