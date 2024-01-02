const fmt = @import("std").fmt;
const mem = @import("std").mem;
const Writer = @import("std").io.Writer;

const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;
const VGA_SIZE = VGA_WIDTH * VGA_HEIGHT;

pub const Colours = enum(u8) {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGray = 7,
    DarkGray = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    LightMagenta = 13,
    LightBrown = 14,
    White = 15,
};

var row: usize = 0;
var column: usize = 0;
var colour = vga_colour(Colours.White, Colours.Black);
var buffer: [*]volatile u16 = @ptrFromInt(0xB8000);

inline fn vga_colour(fg: Colours, bg: Colours) u8 {
    return @intFromEnum(fg) | (@intFromEnum(bg) << 4);
}

inline fn vga_char(uc: u8, new_colour: u8) u16 {
    return uc | (@as(u16, new_colour) << 8);
}

pub fn initialise() void {
    clear();
}

pub fn clear() void {
    @memset(buffer[0..VGA_SIZE], vga_char(' ', colour));
}

pub fn write_char_at(c: u8, new_colour: u8, x: usize, y: usize) void {
    const index = y * VGA_WIDTH + x;
    buffer[index] = vga_char(c, new_colour);
}

pub fn write_char(c: u8) void {
    write_char_at(c, colour, column, row);

    column += 1;
    if (column == VGA_WIDTH) {
        column = 0;
        row += 1;
        if (row == VGA_HEIGHT)
            row = 0;
    }
}

fn handle_control_chars(data: *const []const u8, i: *usize) bool {
    const start_char = data.*[i.*];
    switch (start_char) {
        '\n' => {
            column = 0;
            row += 1;
            return true;
        },
        '\r' => {
            column = 0;
            return true;
        },
        else => return false,
    }
}

pub fn write(data: []const u8) void {
    var i: usize = 0;
    while (i < data.len) : (i += 1) {
        const c = data[i];
        if (handle_control_chars(&data, &i)) {
            continue;
        }
        write_char(c);
    }
}

pub const writer = Writer(void, error{}, callback){ .context = {} };

fn callback(_: void, string: []const u8) error{}!usize {
    write(string);
    return string.len;
}

pub fn printf(comptime format: []const u8, args: anytype) void {
    fmt.format(writer, format, args) catch unreachable;
}
