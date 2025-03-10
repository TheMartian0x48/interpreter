const std = @import("std");

pub const Tag = enum {
    illegal,
    eof,
    ident,
    int,
    assign,
    plus,
    comma,
    semicolon,
    lparen,
    rparen,
    lbrace,
    rbrace,

    pub fn lexeme(tag: Tag) ?[]const u8 {
        return switch (tag) {
            .eof => null,
            .illegal => "illegal",
            .ident => "ident",
            .int => "int",
            .assign => "=",
            .plus => "+",
            .comma => ",",
            .semicolon => ";",
            .lparen => "(",
            .rparen => ")",
            .lbrace => "{",
            .rbrace => "}",
        };
    }
};

pub const Token = struct {
    tag: Tag,
    lexeme: ?[]const u8,

    pub fn create(tag: Tag, lexeme: ?[]const u8) Token {
        return Token{ .tag = tag, .lexeme = lexeme };
    }

    pub fn new(tag: Tag) Token {
        return Token{ .tag = tag, .lexeme = tag.lexeme() };
    }
};
