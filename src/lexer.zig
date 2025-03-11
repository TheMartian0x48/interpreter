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

    pub fn peekChar(l: *Lexer) u8 {
        if (l.readPosition >= l.input.len) {
            return 0;
        } else {
            return l.input[l.readPosition];
        }
    }

    pub fn nextToken(l: *Lexer) token.Token {
        var tok: token.Token = undefined;

        l.skipWhiteSpace();

        switch (l.ch) {
            '=' => {
                if (l.peekChar() == '=') {
                    const lexeme = "==";
                    l.readChar();
                    tok = token.Token.create(token.Tag.eq, lexeme);
                } else {
                    tok = token.Token.new(token.Tag.assign);
                }
            },
            ';' => tok = token.Token.new(token.Tag.semicolon),
            ',' => tok = token.Token.new(token.Tag.comma),
            '(' => tok = token.Token.new(token.Tag.lparen),
            ')' => tok = token.Token.new(token.Tag.rparen),
            '{' => tok = token.Token.new(token.Tag.lbrace),
            '}' => tok = token.Token.new(token.Tag.rbrace),

            '+' => tok = token.Token.new(token.Tag.plus),
            '-' => tok = token.Token.new(token.Tag.minus),

            '*' => tok = token.Token.new(token.Tag.asterisk),
            '!' => {
                if (l.peekChar() == '=') {
                    const lexeme = "!=";
                    l.readChar();
                    tok = token.Token.create(token.Tag.not_eq, lexeme);
                } else {
                    tok = token.Token.new(token.Tag.bang);
                }
            },
            '<' => tok = token.Token.new(token.Tag.lt),
            '>' => tok = token.Token.new(token.Tag.gt),
            '/' => tok = token.Token.new(token.Tag.slash),

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

// test "test code 2" {
//     token.init();
//     const input: []const u8 =
//         \\ let five = 5;
//         \\ let ten = 10;
//         \\ let add = fn(x, y) {
//         \\     x + y;
//         \\ };
//         \\ let result = add(five, ten);
//     ;
//
//     const tests = [_]token.Token{
//         token.Token.new(token.Tag.let),
//         token.Token.new(token.Tag.ident),
//         token.Token.new(token.Tag.assign),
//         token.Token.new(token.Tag.int),
//         token.Token.new(token.Tag.semicolon),
//
//         token.Token.new(token.Tag.let),
//         token.Token.new(token.Tag.ident),
//         token.Token.new(token.Tag.assign),
//         token.Token.new(token.Tag.int),
//         token.Token.new(token.Tag.semicolon),
//
//         token.Token.new(token.Tag.let),
//         token.Token.new(token.Tag.ident),
//         token.Token.new(token.Tag.assign),
//         token.Token.new(token.Tag.function),
//         token.Token.new(token.Tag.lparen),
//         token.Token.new(token.Tag.ident),
//         token.Token.new(token.Tag.comma),
//         token.Token.new(token.Tag.ident),
//         token.Token.new(token.Tag.rparen),
//         token.Token.new(token.Tag.lbrace),
//         token.Token.new(token.Tag.ident),
//         token.Token.new(token.Tag.plus),
//         token.Token.new(token.Tag.ident),
//         token.Token.new(token.Tag.semicolon),
//         token.Token.new(token.Tag.rbrace),
//         token.Token.new(token.Tag.semicolon),
//
//         token.Token.new(token.Tag.let),
//         token.Token.new(token.Tag.ident),
//         token.Token.new(token.Tag.assign),
//         token.Token.new(token.Tag.ident),
//         token.Token.new(token.Tag.lparen),
//         token.Token.new(token.Tag.ident),
//         token.Token.new(token.Tag.comma),
//         token.Token.new(token.Tag.ident),
//         token.Token.new(token.Tag.rparen),
//         token.Token.new(token.Tag.semicolon),
//
//         token.Token.new(token.Tag.eof),
//     };
//     var l = Lexer.new(input);
//
//     for (tests, 0..) |t, i| {
//         std.debug.print("Test token #{d} : {any}\n", .{ i, t.tag.lexeme() });
//         const tok = l.nextToken();
//         std.testing.expectEqual(t.tag, tok.tag) catch |err| {
//             token.deinit();
//             return err;
//         };
//     }
//     token.deinit();
// }
//

test "test code 3" {
    const input: []const u8 =
        \\ !-/*5;
        \\ 5 < 10 > 5;
    ;

    const tests = [_]token.Token{
        token.Token.new(token.Tag.bang),
        token.Token.new(token.Tag.minus),
        token.Token.new(token.Tag.slash),
        token.Token.new(token.Tag.asterisk),
        token.Token.new(token.Tag.int),
        token.Token.new(token.Tag.semicolon),
        token.Token.new(token.Tag.int),
        token.Token.new(token.Tag.lt),
        token.Token.new(token.Tag.int),
        token.Token.new(token.Tag.gt),
        token.Token.new(token.Tag.int),
        token.Token.new(token.Tag.semicolon),

        token.Token.new(token.Tag.eof),
    };
    var l = Lexer.new(input);

    for (tests, 0..) |t, i| {
        std.debug.print("Test token #{d} : {any}\n", .{ i, t.tag.lexeme() });
        const tok = l.nextToken();
        try std.testing.expectEqual(tok.tag, t.tag);
    }
}

// test "test code 4" {
//     const input: []const u8 =
//         \\ if(5 < 10) {
//         \\   return true;
//         \\ } else {
//         \\   return false;
//         \\ }
//     ;
//     token.init();
//
//     const tests = [_]token.Token{
//         token.Token.new(token.Tag.ifT),
//         token.Token.new(token.Tag.lparen),
//         token.Token.new(token.Tag.int),
//         token.Token.new(token.Tag.lt),
//         token.Token.new(token.Tag.int),
//         token.Token.new(token.Tag.rparen),
//         token.Token.new(token.Tag.lbrace),
//         token.Token.new(token.Tag.returnT),
//         token.Token.new(token.Tag.trueT),
//         token.Token.new(token.Tag.semicolon),
//         token.Token.new(token.Tag.rbrace),
//         token.Token.new(token.Tag.elseT),
//         token.Token.new(token.Tag.lbrace),
//         token.Token.new(token.Tag.returnT),
//         token.Token.new(token.Tag.falseT),
//         token.Token.new(token.Tag.semicolon),
//         token.Token.new(token.Tag.rbrace),
//
//         token.Token.new(token.Tag.eof),
//     };
//     var l = Lexer.new(input);
//
//     for (tests, 0..) |t, i| {
//         std.debug.print("Test token #{d} : {any}\n", .{ i, t.tag.lexeme() });
//         const tok = l.nextToken();
//         std.testing.expectEqual(t.tag, tok.tag) catch |err| {
//             token.deinit();
//             return err;
//         };
//     }
//     token.deinit();
// }

test "test code 5" {
    const input: []const u8 =
        \\ 10 == 10;
        \\ 9 != 10;
    ;
    token.init();

    const tests = [_]token.Token{
        token.Token.new(token.Tag.int),
        token.Token.new(token.Tag.eq),
        token.Token.new(token.Tag.int),
        token.Token.new(token.Tag.semicolon),
        token.Token.new(token.Tag.int),
        token.Token.new(token.Tag.not_eq),
        token.Token.new(token.Tag.int),
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
