package main

type TokenType string

const (
	ILLEGAL = "ILLEGAL"
	EOF     = "EOF"

	IDENT = "IDENT"
	INT   = "INT"

	ASSIGN  = "="
	PLUS    = "+"
	MINUS   = "-"
	BANG    = "!"
	ASTRISK = "*"
	SLASH   = "/"

	LT = "<"
	GT = ">"

	COMMA     = ","
	SEMICOLON = ";"

	LPAREN = "("
	RPAREN = ")"
	LBRACE = "{"
	RBRACE = "}"

	FUNCTION = "FUNCTION"
	LET      = "LET"
	TRUE     = "TRUE"
	FALSE    = "FALSE"
	IF       = "IF"
	ELSE     = "ELSE"
	RETURN   = "RETURN"
)

var keywords = map[string]TokenType{
	"fn":     FUNCTION,
	"let":    LET,
	"true":   TRUE,
	"false":  FALSE,
	"if":     IF,
	"else":   ELSE,
	"return": RETURN,
}

func LookupIdent(ident string) TokenType {
	if tok, ok := keywords[ident]; ok {
		return tok
	}
	return IDENT
}

type Token struct {
	Type    TokenType
	Literal string
}

func NewToken(tt TokenType, ch byte) Token {
	return Token{Type: tt, Literal: string(ch)}
}

// LEXER

type Lexer struct {
	input        string
	position     int
	readPosition int
	ch           byte
}

func NewLexer(input string) *Lexer {
	l := &Lexer{input: input}
	l.readChar()
	return l
}

func (l *Lexer) readChar() {
	if l.readPosition >= len(l.input) {
		l.ch = 0
	} else {
		l.ch = l.input[l.readPosition]
	}
	l.position = l.readPosition
	l.readPosition += 1
}
func (l *Lexer) readIdentifier() string {
	position := l.position
	for isLetter(l.ch) {
		l.readChar()
	}
	return l.input[position:l.position]
}
func (l *Lexer) readNumber() string {
	position := l.position
	for isDigit(l.ch) {
		l.readChar()
	}
	return l.input[position:l.position]
}

func (l *Lexer) skipWhitespace() {
	for l.ch == ' ' || l.ch == '\t' || l.ch == '\n' || l.ch == '\r' {
		l.readChar()
	}
}
func isLetter(ch byte) bool {
	return ('a' <= ch && ch <= 'z') || ('A' <= ch && ch <= 'Z') || ch == '_'
}

func isDigit(ch byte) bool {
	return '0' <= ch && ch <= '9'
}

func (l *Lexer) NextToken() Token {
	var tok Token

	l.skipWhitespace()

	switch l.ch {
	case '(':
		tok = NewToken(LPAREN, l.ch)
	case ')':
		tok = NewToken(RPAREN, l.ch)
	case '+':
		tok = NewToken(PLUS, l.ch)
	case ',':
		tok = NewToken(COMMA, l.ch)
	case '-':
		tok = NewToken(MINUS, l.ch)
	case ';':
		tok = NewToken(SEMICOLON, l.ch)
	case '=':
		tok = NewToken(ASSIGN, l.ch)
	case '{':
		tok = NewToken(LBRACE, l.ch)
	case '}':
		tok = NewToken(RBRACE, l.ch)
	case '*':
		tok = NewToken(ASTRISK, l.ch)
	case '!':
		tok = NewToken(BANG, l.ch)
	case '/':
		tok = NewToken(SLASH, l.ch)
	case '<':
		tok = NewToken(LT, l.ch)
	case '>':
		tok = NewToken(GT, l.ch)
	case 0:
		tok.Literal = ""
		tok.Type = EOF
	default:
		if isLetter(l.ch) {
			tok.Literal = l.readIdentifier()
			tok.Type = LookupIdent(tok.Literal)
			return tok
		} else if isDigit(l.ch) {
			tok.Literal = l.readNumber()
			tok.Type = INT
			return tok
		} else {
			tok = NewToken(ILLEGAL, l.ch)
		}
	}
	l.readChar()
	return tok
}
