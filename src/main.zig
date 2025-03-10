const std = @import("std");

pub const token = @import("token/token.zig");

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests. {s}\n", .{token.INT});

    try bw.flush();
}
