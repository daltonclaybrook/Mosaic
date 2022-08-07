# Mosaic Grammar

```
sourceFile      → inSourceDecl* EOF ;
```

## Declarations

```
# Declarations that can appear at the root of a source file
inSourceDecl    → structDecl
                | implDecl
                | funcDecl
                | varDecl ;

structDecl      → "struct" identifier structBlock ;
structBlock     → "{" varDecl* "}" ;

implDecl        → "impl" identifier "{" funcDecl* "}" ;

funcDecl        → "func" identifier "(" funcParams? ")" block ;
funcParams      → funcParam ( "," funcParam )* ;
funcParam       → identifier ":" identifier ;

varDecl         → ( "var" | "const" ) identifier ( ":" identifier )? ( "=" expression )? stmtEnd ;
```

## Statements

```
statement       → varDecl
                | exprStmt
                | eachStmt
                | ifStmt
                | returnStmt
                | breakStmt
                | whileStmt ;

exprStmt        → expression stmtEnd ;
eachStmt        → "each" identifier "in" expression block ;
ifStmt          → "if" expression block ( "else" block )? ;
returnStmt      → "return" expression? stmtEnd ;
breakStmt       → "break" stmtEnd ;
whileStmt       → "while" expression block ;

block           → "{" statement* "}" ;
```

## Expressions

```
expression      → assignment ;
assignment      → identifier "=" assignment
                | logicOr ;
logicOr         → logicAnd ( "||" logicAnd )* ;
logicAnd        → bitwiseOr ( "&&" bitwiseOr )* ;
bitwiseOr       → bitwiseXor ( "|" bitwiseXor )* ;
bitwiseXor      → bitwiseAnd ( "^" bitwiseAnd )* ;
bitwiseAnd      → equality ( "&" equality )* ;
equality        → comparison ( ( "!=" | "==" ) comparison )* ;
comparison      → bitwiseShift ( ( ">" | ">=" | "<" | "<=" ) bitwiseShift )* ;
bitwiseShift    → term ( ( "<<" | ">>" ) term )* ;
term            → factor ( ( "-" | "+" ) factor )* ;
factor          → unary ( ( "/" | "*" | "%" ) unary )* ;
unary           → ( "!" | "-" ) unary
                | primary ;
primary         → literal
                | "nil"
                | "(" expression ")"
                | identifier ;
```

## Primitives

```
identifier    → identifierHead identifierChar* ;

identifierHead  → [a-z] | [A-Z] | "_" ;
identifierChar  → ( identifierHead | decimalDigit ) ;

literal         → numberLiteral | stringLiteral | boolLiteral ;
numberLiteral   → decimalLiteral | hexLiteral | binaryLiteral ;

decimalLiteral  → decimalDigit+ ( "." decimalDigit+ )? ;
decimalDigit    → [0-9] ;

hexLiteral      → "0x" hexDigit+ ;
hexDigit        → decimalDigit | [a-f] | [A-F] ;

binaryLiteral   → "0b" binaryDigit+ ;
binaryDigit     → "0" | "1" ;

stringLiteral   → "\"" stringChar* "\"" ;
stringChar      → ASCII character ;

boolLiteral     → "true" | "false" ;

stmtEnd         → "\n" | scopeEnd ;
scopeEnd        → The end of a block or source file
```
