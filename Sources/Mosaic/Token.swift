/// A single token parsed from a Mosaic source file
public struct Token: Equatable {
	/// The type of the token
	public let type: TokenType
	/// The line where the token occurs in the source file
	public let line: Int
	/// The column where the token occurs in the source file
	public let column: Int
	/// The string lexeme of the token
	public let lexeme: String
	/// Whether this token is terminated with a newline character
	public var isTerminatedWithNewline: Bool
}
