struct ParseContext {
	var isInLoop: Bool {
		nestedLoops > 0
	}

	private var nestedLoops = 0

	mutating func nestLoop<T>(with block: (inout ParseContext) throws -> T) rethrows -> T {
		nestedLoops += 1
		defer { nestedLoops -= 1 }
		return try block(&self)
	}
}
