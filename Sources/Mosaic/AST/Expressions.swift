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
	case grouping(Expression)
	case boolLiteral(Bool)
	case nilLiteral
	case integerLiteral(Token)
	case fixedLiteral(Token)
	case stringLiteral(Token)
	case arrayLiteral(Token)
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
