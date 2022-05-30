import Foundation

extension Character {
	/// [a-z] | [A-Z] | "_"
	var isIdentifierHead: Bool {
		isLetter || self == "_"
	}

	var isIdentifierChar: Bool {
		isIdentifierHead || isNumber
	}
}
