public enum ParseError: Error {
	case unrecognizedCharacter(Character)
	case unterminatedString(String)
}
