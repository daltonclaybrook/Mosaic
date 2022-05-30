public struct Token: Equatable {
	public let type: TokenType
	public let line: Int
	public let column: Int
	public let lexeme: String
}
