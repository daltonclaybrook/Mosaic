//expression      → assignment ;
//assignment      → simpleIdentifier "=" assignment
//				| logicOr ;
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
//				| primary ;
//primary         → literal
//				| "nil"
//				| "(" expression ")"
//				| simpleIdentifier ;

public protocol Expression {}

/// A dot-delimited list of identifiers representing a getter.
public struct Getter: Expression {
	/// If `self` is used in the getter, this field is non-nil
	public var selfToken: Token?
	/// The list of dot-delimited identifiers
	public var identifiers: [Identifier]
}

public struct Binary: Expression {
	public enum Operator {
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

public struct Unary: Expression {
	public enum Operator {
		case not
		case negate
	}

	public var expression: Expression
	public var `operator`: Operator
}

public struct Primary: Expression {}
