const std = @import("std");
const allocator = std.heap.page_allocator;

const memory_size = 30_000;
const max_file_size = 1024 * 1024 * 1024;

const Data = u9;
const Index = u32;
const ProgramCounter = u32;

pub fn interpret(program: []const u8, reader: anytype, writer: anytype, error_writer: anytype) anyerror!void {
    var memory = [_]Data{0} ** memory_size;
    var index: Index = 0;
    var program_counter: ProgramCounter = 0;
    var was_read = false;

    while (program_counter < program.len) {
        const character = program[program_counter];
	std.debug.assert(0 <= character and character <= 256);

        switch (character) {
            '>' => {
                if (index == memory_size - 1) {
                    try error_writer.print("Error: index out of upper bounds at char {d}\n", .{program_counter});
                    return error.IndexOutOfBounds;
                }
                index += 1;
		was_read = false;
            },
            '<' => {
                if (index == 0) {
                    try error_writer.print("Error: index out of lower bounds at char {d}\n", .{program_counter});
                    return error.IndexOutOfBounds;
                }
                index -= 1;
		was_read = false;
            },
            '+' => {
                memory[index] += 1; memory[index] %= 257;
		was_read = false;
            },
            '-' => {
		if (memory[index] > 0) memory[index] -= 1
		else memory[index] = 256;
		was_read = false;
            },
            '.' => {
		if ( memory[index] == 256 ) {
		    memory[index] = reader.readByte() catch 256;
		    was_read = true;
		} else {
                    const out_byte: u8 = @intCast(memory[index]);
                    try writer.writeByte(out_byte);
		    was_read = false;
		}
            },
            '[' => {
		const enter_loop = if (was_read) memory[index] != 256 else memory[index] != 0;
                if (!enter_loop) {
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
		was_read = false;
            },
            ']' => {
		const enter_loop = if (was_read) memory[index] != 256 else memory[index] != 0;
                if (enter_loop) {
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
		was_read = false;
            },
            else => {},
        }
        program_counter += 1;
    }
}
