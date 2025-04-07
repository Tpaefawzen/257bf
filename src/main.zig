const std = @import("std");
const allocator = std.heap.page_allocator;

const memory_size = 30_000;
const max_file_size = 1024 * 1024 * 1024;

pub fn main() anyerror!void {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr().writer();

    if (args.len != 2 and !(args.len == 3 and std.mem.eql(u8, args[1], "-e"))) {
        try stderr.print("usage: brainfuck [-e expression] [file path]\n", .{});
        std.process.exit(1);
    }

    if (args.len == 3) {
        const program = args[2];
        interpret(program, stdin, stdout, stderr) catch std.process.exit(1);
    } else if (args.len == 2) {
        const file_path = args[1];
        const program = std.fs.cwd().readFileAlloc(allocator, file_path, max_file_size) catch {
            try stderr.print("File not found: {s}\n", .{file_path});
            std.process.exit(1);
        };
        defer allocator.free(program);
        interpret(program, stdin, stdout, stderr) catch std.process.exit(1);
    }
}

const interpret = @import("257bf.zig").interpret;

comptime {
    _ = &@import("257bf.zig");
}
