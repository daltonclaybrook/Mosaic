# Mosaic Grammar

```
sourceFile      → declaration* EOF ;
```

## Declarations

```
# Declarations that can appear at the root of a source file
inSourceDecl    → structDecl
                | implDecl
                | inStructDecl ;

# Declarations that can appear inside a struct or impl
inStructDecl    → funcDecl | varDecl ;

structDecl      → "struct" simpleIdentifier ( "<" structGeneric ( "," structGeneric )* ">" ) ;
structGeneric   → ( "'"? simpleIdentifier ( ":" simpleIdentifier )? ) ;

implDecl        → "impl" simpleIdentifier "{" declaration* "}" ;

funcDecl        → "func" simpleIdentifier "(" parameters? ")" block ;
funcParams      → funcParam ( "," funcParam )* ;
funcParam       → simpleIdentifier ":" simpleIdentifier ;

varDecl         → ( "var" | "const" ) simpleIdentifier ( ":" typeIdentifier )? ( "=" expression )? stmtEnd ;
```

## Statements

```
statement       → varDecl
                | exprStmt
                | eachStmt
                | ifStmt
                | whileStmt ;

exprStmt        → expression stmtEnd ;
eachStmt        → "each" simpleIdentifier "in" expression block ;
ifStmt          → "if" expression block ( "else" block )? ;
whileStmt       → "while" expression block ;

block           → "{" statement* "}" ;
```

## Expressions

```
expression      → assignment ;
assignment      → simpleIdentifier "=" assignment
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
                | simpleIdentifier ;
```

## Primitives

```
simpleIdentifier    → identifierHead identifierChar* ;
genericIdentifier   → simpleIdentifier ( "<" ( typeIdentifier | literal ) ">" ) ;
typeIdentifier  → simpleIdentifier | genericIdentifier ;

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
