/// All possible "statements"
public enum Statement {
	case variable(VariableDeclaration)
	case expression(Expression)
	case each(EachStatement)
	case `if`(IfStatement)
	case `return`(ReturnStatement)
	case `break`(BreakStatement)
	case `while`(WhileStatement)
}

/// A loop that iterates through each element of a collection
public struct EachStatement {
	/// The "element" identifier token that points to the current element in
	/// the collection being iterated
	public var element: Token
	/// The collection of elements being iterated
	public var collection: Expression
	/// The list of statements that make up the body of the each statement.
	public var body: [Statement]
}

/// An if statement
public struct IfStatement {
	/// The condition that is evaluated to determine which branch to execute
	public var condition: Expression
	/// Statements that are evaluated if the condition evalutates to true
	public var thenBranch: [Statement]
	/// Statements that are evaluated if the condition evaluates to false
	public var elseBranch: [Statement]?
}

/// A return statement used to exit a function
public struct ReturnStatement {
	/// An expression that is evaluated to produce the return value
	public var value: Expression?
}

/// A break statement used to exit a loop
public struct BreakStatement {
}

/// A while loop
public struct WhileStatement {
	/// The condition that is evaluated to determine if the body should continue to be evaluated
	public var condition: Expression
	/// The body of the while statement that is evaluated repeatedly as long as `condition`
	/// evaluates to `true`
	public var body: [Statement]
}
