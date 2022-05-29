## Integers

```mosaic
// Simple variable. type inferred to UInt8
var foo = 123

// Type inferred to UInt16 since literal is over 255
var foo = 1234

// Specify the type explicitly
var foo: UInt8 = 123

// Compiler error. UInt8 cannot be created from a literal this large.
var foo: UInt8 = 1234

// Constant literal. Type is inferred to StaticInt.
const foo = 123
var bar = 7 // UInt8
const baz = foo + bar // This is legal. baz is a UInt8
```

## Fixed-point numbers

```mosaic
// Type inferred to UFixed<1>
var foo = 12.3

// Constant literal. Type inferred to StaticFixed<2>.
const foo = 12.34
var bar = 1.23 // UFixed<2>
var baz = bar + foo // Legal. baz is UFixed<2>
```

## Literals

```mosaic
123 // Integer literal
12.3 // Fixed-point literal
"abcd" // String literal
0x1A2F // Integer literal, hex notation
0b0110 // Integer literal, binary notation
```

## Functions

```mosaic
func addNumbers(foo: UInt8, bar: UInt8) -> UInt8 {
    return foo + bar
}
```

## Loops

```mosaic
each index in 0..<12 {
    // ...
}

while foo < 12 {
    // ...
}
```
