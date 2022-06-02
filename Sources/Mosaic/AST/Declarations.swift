/// A single Mosaic source file, which may be one file among many that comprise the program
public struct SourceFile {
	/// A sequential list of declarations in the source file
	public var declarations: [InSourceDeclaration]
	/// The end-of-file token
	public var endOfFile: Token
}

/// A declaration that can appear at the top level in a source file
public enum InSourceDeclaration {
	case structure(StructDeclaration)
	case function(FuncDeclaration)
	case variable(VariableDeclaration)
}

/// A struct declaration, which is a named collection of variables.
public struct StructDeclaration {
	public var type: TypeDeclaration
	public var variables: [VariableDeclaration]
}

/// An implementation of a struct, which is a collection of methods
public struct ImplDeclaration {
	/// The list of method declarations contained within this implementation body
	public var methods: [FuncDeclaration]
}

/// A function declaration, which is a collection of statements
public struct FuncDeclaration {
	public struct Parameter {
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
public struct VariableDeclaration {
	public enum Mutability {
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

/// A type declaration is used when declaring a struct. It is different than a type identifier.
public struct TypeDeclaration {
	/// The base name of the type
	public var nameIdentifier: Token
	/// The list of generics if present
	public var generics: [GenericDeclaration]
}

/// A type can be generic over a type or a value
public enum GenericDeclaration {
	case type(name: Token)
	case value(name: Token, type: TypeIdentifier)
}

public enum GenericIdentifier {
	case type(TypeIdentifier)
	case value(Literal)
}

/// A type identifier is used when annotating the type of a variable or function parameter.
/// It is different from a type declaration.
public struct TypeIdentifier {
	/// The base name of the type
	public var nameIdentifier: Token
	/// The list of generics if present
	public var generics: [GenericIdentifier]
}
