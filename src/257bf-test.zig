const std=@import("std");
const testing=std.testing;
const interpret=@import("257bf.zig").interpret;
const memory_size = 30_000;
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

    try std.testing.expectEqualStrings("8 bit cells\n", output.items);
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
