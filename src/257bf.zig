const std = @import("std");
const testing = std.testing;
const allocator = std.heap.page_allocator;

const memory_size = 30_000;
const max_file_size = 1024 * 1024 * 1024;

pub fn interpret(program: []const u8, reader: anytype, writer: anytype, error_writer: anytype) anyerror!void {
    var memory = [_]u8{0} ** memory_size;
    var index: u32 = 0;
    var program_counter: u32 = 0;

    while (program_counter < program.len) {
        const character = program[program_counter];

        switch (character) {
            '>' => {
                if (index == memory_size - 1) {
                    try error_writer.print("Error: index out of upper bounds at char {d}\n", .{program_counter});
                    return error.IndexOutOfBounds;
                }
                index += 1;
            },
            '<' => {
                if (index == 0) {
                    try error_writer.print("Error: index out of lower bounds at char {d}\n", .{program_counter});
                    return error.IndexOutOfBounds;
                }
                index -= 1;
            },
            '+' => {
                memory[index] +%= 1;
            },
            '-' => {
                memory[index] -%= 1;
            },
            '.' => {
                const out_byte: u8 = memory[index];
                try writer.writeByte(out_byte);
            },
            ',' => {
                memory[index] = reader.readByte() catch 0;
            },
            '[' => {
                if (memory[index] == 0) {
                    const start = program_counter;
                    var depth: u32 = 1;
                    while (program_counter < program.len - 1) {
                        program_counter += 1;
                        const seek_char = program[program_counter];
                        if (seek_char == ']') {
                            depth -= 1;
                        }
                        if (depth == 0) {
                            break;
                        }
                        if (seek_char == '[') {
                            depth += 1;
                        }
                    }
                    if (program_counter == program.len - 1 and depth != 0) {
                        try error_writer.print("Error: missing closing braket to opening bracket at char {d}\n", .{start});
                        return error.MissingClosingBracket;
                    }
                }
            },
            ']' => {
                if (memory[index] != 0) {
                    const start = program_counter;
                    var depth: u32 = 1;
                    while (program_counter > 0) {
                        program_counter -= 1;
                        const seek_char = program[program_counter];
                        if (seek_char == '[') {
                            depth -= 1;
                        }
                        if (depth == 0) {
                            break;
                        }
                        if (seek_char == ']') {
                            depth += 1;
                        }
                    }
                    if (program_counter == 0 and depth != 0) {
                        try error_writer.print("Error: missing opening bracket to closing bracket at char {d}\n", .{start});
                        return error.MissingOpeningBracket;
                    }
                }
            },
            else => {},
        }
        program_counter += 1;
    }
}

test "get cell bit width brainfuck" {
    const program =
        \\ // This generates 65536 to check for larger than 16bit cells
        \\ [-]>[-]++[<++++++++>-]<[>++++++++<-]>[<++++++++>-]<[>++++++++<-]>[<+++++
        \\ +++>-]<[[-]
        \\ [-]>[-]+++++[<++++++++++>-]<+.-.
        \\ [-]]
        \\ // This section is cell doubling for 16bit cells
        \\ >[-]>[-]<<[-]++++++++[>++++++++<-]>[<++++>-]<[->+>+<<]>[<++++++++>-]<[>+
        \\ +++++++<-]>[<++++>-]>[<+>[-]]<<[>[-]<[-]]>[-<+>]<[[-]
        \\ [-]>[-]+++++++[<+++++++>-]<.+++++.
        \\ [-]]
        \\ // This section is cell quadrupling for 8bit cells
        \\ [-]>[-]++++++++[<++++++++>-]<[>++++<-]+>[<->[-]]<[[-]
        \\ [-]>[-]+++++++[<++++++++>-]<.
        \\ [-]]
        \\ [-]>[-]++++[-<++++++++>]<.[->+++<]>++.+++++++.+++++++++++.[----<+>]<+++.
        \\ +[->+++<]>.++.+++++++..+++++++.[-]++++++++++.[-]<
    ;
    var output = std.ArrayList(u8).init(std.testing.allocator);
    defer output.deinit();

    const stdin = std.io.getStdIn().reader();
    const stdout = output.writer();
    const stderr = std.io.null_writer;

    try interpret(program, stdin, stdout, stderr);

    try std.testing.expectEqualStrings("32 bit cells\n", output.items);
}

test "write in cell outside of array bottom" {
    const program = "<<<+";
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.null_writer;
    const stderr = std.io.null_writer;

    const output = interpret(program, stdin, stdout, stderr);
    try testing.expectError(error.IndexOutOfBounds, output);
}

test "write in cell outside of array top" {
    const program = ">" ** memory_size;
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.null_writer;
    const stderr = std.io.null_writer;

    const output = interpret(program, stdin, stdout, stderr);
    try testing.expectError(error.IndexOutOfBounds, output);
}

test "write number over 255 to writer" {
    const program = "+" ** 300 ++ ".";
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.null_writer;
    const stderr = std.io.null_writer;

    try interpret(program, stdin, stdout, stderr);
}

test "write negative number to writer" {
    const program = "-" ** 200 ++ ".";
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.null_writer;
    const stderr = std.io.null_writer;

    try interpret(program, stdin, stdout, stderr);
}

test "loop without end" {
    const program = "[><";
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.null_writer;
    const stderr = std.io.null_writer;

    const output = interpret(program, stdin, stdout, stderr);
    try testing.expectError(error.MissingClosingBracket, output);
}

test "loop without beginning" {
    const program = "+><]";
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.null_writer;
    const stderr = std.io.null_writer;

    const output = interpret(program, stdin, stdout, stderr);
    try testing.expectError(error.MissingOpeningBracket, output);
}
