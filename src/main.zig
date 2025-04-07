const std = @import("std");
const allocator = std.heap.page_allocator;

const memory_size = 30_000;
const max_file_size = 1024 * 1024 * 1024;

fn usage() noreturn {
    std.debug.print(
	\\ Usage: 257bf FILE
	\\        257bf --code=CODE
	\\
	, .{});
    std.process.exit(1);
}

pub fn main() anyerror!void {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr().writer();

    if (args.len < 2)
	usage();

    var code: ?[]const u8 = null;
    var file: ?[]const u8 = null;

    if (std.mem.eql(u8, args[1], "--code")) {
	if (args.len < 3) return error.MissingOptionValue;
	code = args[2];
    } else if (std.mem.startsWith(u8, args[1], "--code=")) {
	code = args[1][7..];
    } else if (std.mem.eql(u8, args[1], "-")) {
	file = args[1];
    } else if (std.mem.startsWith(u8, args[1], "-")) {
	return error.UnknownOption;
    } else {
	file = args[1];
    }

    if (code) |c| {
        const program = c;
        interpret(program, stdin, stdout, stderr) catch std.process.exit(1);
    } else if (file) |f| {
        const file_path = f;
        const program = std.fs.cwd().readFileAlloc(allocator, file_path, max_file_size) catch {
            try stderr.print("File not found: {s}\n", .{file_path});
            std.process.exit(1);
        };
        defer allocator.free(program);
        interpret(program, stdin, stdout, stderr) catch std.process.exit(1);
    } else {
	unreachable;
    }
}

const interpret = @import("257bf.zig").interpret;

comptime {
    _ = &@import("257bf-test.zig");
}
