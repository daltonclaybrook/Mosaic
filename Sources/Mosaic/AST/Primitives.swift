/// A primitive literal
public struct Literal {
	public enum Kind {
		case `nil`
		case boolean
		case integer
		case fixed
	}

	/// The token of the literal
	public var token: Token
	/// The kind of the literal
	public var kind: Kind
}

/// A simple identifier
public struct Identifier {
	/// The token of the identifier
	var token: Token
}
