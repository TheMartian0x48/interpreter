const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
var keywords: ?std.StringHashMap(Tag) = null;

pub fn init() void {
    if (keywords == null) {
        keywords = std.StringHashMap(Tag).init(allocator);

        keywords.?.put("fn", Tag.function) catch {};
        keywords.?.put("let", Tag.let) catch {};
        keywords.?.put("true", Tag.trueT) catch {};
        keywords.?.put("false", Tag.falseT) catch {};
        keywords.?.put("if", Tag.ifT) catch {};
        keywords.?.put("else", Tag.elseT) catch {};
        keywords.?.put("return", Tag.returnT) catch {};
    }
}

pub fn deinit() void {
    if (keywords != null) {
        keywords.?.deinit();
    }
}

pub fn lookupKeyword(keyword: []const u8) Tag {
    return keywords.?.get(keyword) orelse Tag.ident;
}

pub const Tag = enum {
    illegal,
    eof,
    ident,
    assign,

    int,
    plus,
    minus,

    lparen,
    rparen,
    lbrace,
    rbrace,

    function,
    let,
    bang,
    asterisk,
    slash,
    comma,
    semicolon,

    gt,
    lt,

    trueT,
    falseT,

    ifT,
    elseT,
    returnT,

    eq,
    not_eq,

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
            .function => "fn",
            .let => "let",
            .gt => ">",
            .lt => "<",
            .minus => "-",
            .bang => "!",
            .asterisk => "*",
            .slash => "/",
            .trueT => "true",
            .falseT => "false",
            .ifT => "if",
            .elseT => "else",
            .returnT => "return",
            .eq => "==",
            .not_eq => "!=",
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
