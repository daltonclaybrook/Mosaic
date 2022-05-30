/// A convenience utility for scanning the contents of a string and preserving line/column numbers
public struct Cursor {
	public let string: String
	public private(set) var currentIndex: String.Index

	public private(set) var currentLine = 1
	public private(set) var currentColumn = 1

	public var isAtEnd: Bool {
		currentIndex >= string.endIndex
	}

	/// The previously scanned character
	public var previous: Character {
		guard currentIndex > string.startIndex else { return "\0" }
		return string[string.index(before: currentIndex)]
	}

	public init(string: String) {
		self.string = string
		self.currentIndex = string.startIndex
	}

	/// Advance the current index and return the next character
	@discardableResult
	public mutating func advance() -> Character {
		guard !isAtEnd else {
			fatalError("Attempted to advance while already past the end of the string")
		}

		let current = string[currentIndex]
		currentIndex = string.index(after: currentIndex)
		advanceLineAndColumn(for: current)
		return current
	}

	/// If the next scanned character matches the provided character, advance the cursor and return
	/// `true`. Otherwise, do not advance the cursor and return `false`.
	public mutating func match(next: Character) -> Bool {
		match { $0 == next }
	}

	/// If the next scanned character passes the provided predicate closure, advance the cursor and return
	/// `true`. Otherwise, do not advance the cursor and return `false`.
	public mutating func match(_ predicate: (Character) -> Bool) -> Bool {
		guard !isAtEnd else { return false }

		let current = string[currentIndex]
		guard predicate(current) else { return false}

		currentIndex = string.index(after: currentIndex)
		advanceLineAndColumn(for: current)
		return true
	}

	/// Returns the next character in the string after `count` characters. Does not advance the current index.
	/// Return the next character in the string without advancing the current index
	public func peek(count: Int = 0) -> Character {
		guard
			let desiredIndex = string.index(currentIndex, offsetBy: count, limitedBy: string.endIndex),
			desiredIndex < string.endIndex
		else { return "\0" }

		return string[desiredIndex]
	}

	// MARK: - Private helpers

	private mutating func advanceLineAndColumn(for next: Character) {
		if next.isNewline {
			currentLine += 1
			currentColumn = 1
		} else {
			currentColumn += 1
		}
	}
}
