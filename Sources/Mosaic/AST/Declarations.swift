/// A single Mosaic source file, which may be one file among many that comprise the program
public struct SourceFile: Equatable {
	/// A sequential list of declarations in the source file
	public var declarations: [InSourceDeclaration]
	/// The end-of-file token
	public var endOfFile: Token
}

/// A declaration that can appear at the top level in a source file
public enum InSourceDeclaration: Equatable {
	case structure(StructDeclaration)
	case structImpl(ImplDeclaration)
	case function(FuncDeclaration)
	case variable(VariableDeclaration)
}

/// A struct declaration, which is a named collection of variables.
public struct StructDeclaration: Equatable {
	public var type: TypeIdentifier
	public var variables: [VariableDeclaration]
}

/// An implementation of a struct, which is a collection of methods
public struct ImplDeclaration: Equatable {
	public var type: TypeIdentifier
	/// The list of method declarations contained within this implementation body
	public var methods: [FuncDeclaration]
}

/// A function declaration, which is a collection of statements
public struct FuncDeclaration: Equatable {
	public struct Parameter: Equatable {
		public var name: Token
		public var type: TypeIdentifier
	}

	/// The name of the function
	public var nameIdentifier: Token
	/// The function's parameters
	public var parameters: [Parameter]
	/// The function's return type, if it return's a value
	public var returnType: TypeIdentifier?
	/// The list of statements contained within the body of the function
	public var statements: [Statement]
}

/// A named variable declaration
public struct VariableDeclaration: Equatable {
	public enum Mutability: Equatable {
		case constant, variable
	}

	/// Whether this variable is declared as a `const` or `var`
	public var mutability: Mutability
	/// The name of this variable
	public var nameIdentifier: Token
	/// The type name of this variable if one is provided
	public var typeIdentifier: TypeIdentifier?
	/// The initial value of this variable, if one is provided
	public var initialValue: Expression?
}

/// A type identifier is used when annotating the type of a variable or function parameter,
/// Or when declaring a new type.
public struct TypeIdentifier: Equatable {
	/// The base name of the type
	public var nameIdentifier: Token
}
