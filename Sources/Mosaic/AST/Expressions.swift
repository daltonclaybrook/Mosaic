//expression      → logicOr ;
//logicOr         → logicAnd ( "||" logicAnd )* ;
//logicAnd        → bitwiseOr ( "&&" bitwiseOr )* ;
//bitwiseOr       → bitwiseXor ( "|" bitwiseXor )* ;
//bitwiseXor      → bitwiseAnd ( "^" bitwiseAnd )* ;
//bitwiseAnd      → equality ( "&" equality )* ;
//equality        → comparison ( ( "!=" | "==" ) comparison )* ;
//comparison      → bitwiseShift ( ( ">" | ">=" | "<" | "<=" ) bitwiseShift )* ;
//bitwiseShift    → term ( ( "<<" | ">>" ) term )* ;
//term            → factor ( ( "-" | "+" ) factor )* ;
//factor          → unary ( ( "/" | "*" | "%" ) unary )* ;
//unary           → ( "!" | "-" ) unary
//				| call ;
//call            → getter "(" arguments? ")" ;
//				| primary ;
//arguments       → expression ( "," expression )* ;
//primary         → literal
//				| "nil"
//				| "(" expression ")"
//				| getter ;
//getter          → ( "self" | identifier ) ( "." identifier )*

public indirect enum Expression: Equatable {
	case getter(Getter)
	case binary(Binary)
	case unary(Unary)
	case call(Call)
	case grouping(Grouping)
	case boolLiteral(BoolLiteral)
	case nilLiteral(NilLiteral)
	case integerLiteral(IntegerLiteral)
	case fixedLiteral(FixedLiteral)
	case stringLiteral(StringLiteral)
	case arrayLiteral(ArrayLiteral)
}

/// A dot-delimited list of identifiers representing a getter.
public struct Getter: Equatable {
	/// If `self` is used in the getter, this field is non-nil
	public var selfToken: Token?
	/// The list of dot-delimited identifiers
	public var identifiers: [Identifier]
}

public struct Binary: Equatable {
	public enum Operator: Equatable {
		case logicOr
		case logicAnd
		case bitwiseOr
		case bitwiseXor
		case bitwiseAnd
		case equal
		case notEqual
		case greaterThan
		case greaterThanOrEqual
		case lessThan
		case lessThanOrEqual
		case leftShift
		case rightShift
		case plus
		case minus
		case divide
		case multiply
		case remainder
	}

	public var left: Expression
	public var right: Expression
	public var `operator`: Operator
}

public struct Unary: Equatable {
	public enum Operator: Equatable {
		case not
		case negate
	}

	public var expression: Expression
	public var `operator`: Operator
}

public struct Call: Equatable {
	public var callable: Getter
	public var arguments: [Expression]
}

public struct Grouping: Equatable {
	public var grouped: Expression
}

// MARK: - Literals

public struct BoolLiteral: Equatable {
	public var value: Bool
}

public struct NilLiteral: Equatable {}

public struct IntegerLiteral: Equatable {
	public var token: Token
}

public struct FixedLiteral: Equatable {
	public var token: Token
}

public struct StringLiteral: Equatable {
	public var token: Token
}

public struct ArrayLiteral: Equatable {
	public var token: Token
}
