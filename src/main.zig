const std = @import("std");

pub const token = @import("token.zig");
pub const lexer = @import("lexer.zig");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();
    var buffer: [1024]u8 = undefined;
    @memset(buffer[0..], 0);

    token.init();
    while (true) {
        try stdout.writeAll(" >> ");
        const in = try stdin.readUntilDelimiterOrEof(buffer[0..], '\n');
        const fin = in orelse "";
        var l = lexer.Lexer.new(fin);
        var tok = l.nextToken();
        while (tok.tag != token.Tag.eof) {
            const t = tok.tag.lexeme();
            try stdout.writeAll(t orelse "null");
            try stdout.writeAll("\t\t : ");
            try stdout.writeAll(tok.lexeme orelse "null");
            try stdout.writeAll("\n");
            tok = l.nextToken();
        }
    }
    token.deinit();
}
