//statement       → varDecl
//				| exprStmt
//				| eachStmt
//				| ifStmt
//				| returnStmt
//				| breakStmt
//				| whileStmt ;
//
//exprStmt        → expression stmtEnd ;
//eachStmt        → "each" simpleIdentifier "in" expression block ;
//ifStmt          → "if" expression block ( "else" block )? ;
//returnStmt      → "return" expression? stmtEnd ;
//breakStmt       → "break" stmtEnd ;
//whileStmt       → "while" expression block ;
//
//block           → "{" statement* "}" ;

public enum Statement {
	case variable(VariableDeclaration)
	case expression(Expression)
	case each(EachStatement)
}

/// A loop that iterates through each element of a collection
public struct EachStatement {
	/// The "element" identifier token that points to the current element in
	/// the collection being iterated
	public var element: Token
	/// The collection of elements being iterated
	public var collection: Expression
	/// The list of statements contained within the each block evaluated once
	/// per iteration
	public var statements: [Statement]
}
