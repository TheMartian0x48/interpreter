const std = @import("std");

const token = @import("token.zig");

pub fn isLetter(ch: u8) bool {
    return switch (ch) {
        'A'...'Z', 'a'...'z', '_' => true,
        else => false,
    };
}

pub fn isDigit(ch: u8) bool {
    return switch (ch) {
        '0'...'9' => true,
        else => false,
    };
}

pub const Lexer = struct {
    position: usize,
    readPosition: usize,
    ch: u8,
    input: []const u8,

    pub fn new(input: []const u8) Lexer {
        var lexer = Lexer{ .position = 0, .readPosition = 0, .input = input, .ch = 0 };
        lexer.readChar();
        return lexer;
    }

    pub fn readChar(l: *Lexer) void {
        if (l.readPosition >= l.input.len) {
            l.ch = 0;
        } else {
            l.ch = l.input[l.readPosition];
        }
        l.position = l.readPosition;
        l.readPosition += 1;
    }

    pub fn readIdentifier(l: *Lexer) []const u8 {
        const position = l.position;
        while (isLetter(l.ch)) {
            l.readChar();
        }
        return l.input[position..l.position];
    }

    pub fn readNumber(l: *Lexer) []const u8 {
        const position = l.position;
        while (isDigit(l.ch)) {
            l.readChar();
        }
        return l.input[position..l.position];
    }

    pub fn skipWhiteSpace(l: *Lexer) void {
        while (l.ch == ' ' or l.ch == '\t' or l.ch == '\n' or l.ch == '\r') {
            l.readChar();
        }
    }

    pub fn nextToken(l: *Lexer) token.Token {
        var tok: token.Token = undefined;

        l.skipWhiteSpace();

        switch (l.ch) {
            '=' => tok = token.Token.new(token.Tag.assign),
            ';' => tok = token.Token.new(token.Tag.semicolon),
            ',' => tok = token.Token.new(token.Tag.comma),

            '(' => tok = token.Token.new(token.Tag.lparen),
            ')' => tok = token.Token.new(token.Tag.rparen),
            '{' => tok = token.Token.new(token.Tag.lbrace),
            '}' => tok = token.Token.new(token.Tag.rbrace),

            '+' => tok = token.Token.new(token.Tag.plus),

            0 => tok = token.Token.new(token.Tag.eof),
            else => {
                if (isLetter(l.ch)) {
                    const lexeme = l.readIdentifier();
                    const tag = token.lookupKeyword(lexeme);
                    tok = token.Token.create(tag, lexeme);
                    return tok;
                } else if (isDigit(l.ch)) {
                    const lexeme = l.readNumber();
                    tok = token.Token.create(token.Tag.int, lexeme);
                    return tok;
                } else {
                    tok = token.Token.new(token.Tag.illegal);
                }
            },
        }
        l.readChar();
        return tok;
    }
};

// TEST

// test "test code 1" {
//     const input: []const u8 = "=+(){},;";
//
//     const tests = [_]token.Token{
//         token.Token.new(token.Tag.assign),
//         token.Token.new(token.Tag.plus),
//         token.Token.new(token.Tag.lparen),
//         token.Token.new(token.Tag.rparen),
//         token.Token.new(token.Tag.lbrace),
//         token.Token.new(token.Tag.rbrace),
//         token.Token.new(token.Tag.comma),
//         token.Token.new(token.Tag.semicolon),
//
//         token.Token.new(token.Tag.eof),
//     };
//     var l = Lexer.new(input);
//
//     for (tests, 0..) |t, i| {
//         std.debug.print("Test token #{d} : {any}\n", .{ i, t.tag.lexeme() });
//         const tok = l.nextToken();
//         try std.testing.expectEqual(tok.tag, t.tag);
//     }
// }

test "test code 2" {
    token.init();
    const input: []const u8 =
        \\ let five = 5;
        \\ let ten = 10;
        \\ let add = fn(x, y) {
        \\     x + y;
        \\ };
        \\ let result = add(five, ten);
    ;

    const tests = [_]token.Token{
        token.Token.new(token.Tag.let),
        token.Token.new(token.Tag.ident),
        token.Token.new(token.Tag.assign),
        token.Token.new(token.Tag.int),
        token.Token.new(token.Tag.semicolon),

        token.Token.new(token.Tag.let),
        token.Token.new(token.Tag.ident),
        token.Token.new(token.Tag.assign),
        token.Token.new(token.Tag.int),
        token.Token.new(token.Tag.semicolon),

        token.Token.new(token.Tag.let),
        token.Token.new(token.Tag.ident),
        token.Token.new(token.Tag.assign),
        token.Token.new(token.Tag.function),
        token.Token.new(token.Tag.lparen),
        token.Token.new(token.Tag.ident),
        token.Token.new(token.Tag.comma),
        token.Token.new(token.Tag.ident),
        token.Token.new(token.Tag.rparen),
        token.Token.new(token.Tag.lbrace),
        token.Token.new(token.Tag.ident),
        token.Token.new(token.Tag.plus),
        token.Token.new(token.Tag.ident),
        token.Token.new(token.Tag.semicolon),
        token.Token.new(token.Tag.rbrace),
        token.Token.new(token.Tag.semicolon),

        token.Token.new(token.Tag.let),
        token.Token.new(token.Tag.ident),
        token.Token.new(token.Tag.assign),
        token.Token.new(token.Tag.ident),
        token.Token.new(token.Tag.lparen),
        token.Token.new(token.Tag.ident),
        token.Token.new(token.Tag.comma),
        token.Token.new(token.Tag.ident),
        token.Token.new(token.Tag.rparen),
        token.Token.new(token.Tag.semicolon),

        token.Token.new(token.Tag.eof),
    };
    var l = Lexer.new(input);

    for (tests, 0..) |t, i| {
        std.debug.print("Test token #{d} : {any}\n", .{ i, t.tag.lexeme() });
        const tok = l.nextToken();
        std.testing.expectEqual(t.tag, tok.tag) catch |err| {
            token.deinit();
            return err;
        };
    }
    token.deinit();
}
