const tty = @import("tty.zig");
const io = @import("cpu/io.zig");

const ALIGN = 1 << 0;
const MEMINFO = 1 << 1;
const MAGIC = 0x1BADB002;
const FLAGS = ALIGN | MEMINFO;

const MultibootHeader = extern struct {
    magic: i32 = MAGIC,
    flags: i32 = FLAGS,
    checksum: i32 = -(MAGIC + FLAGS),
};

export const multiboot align(4) linksection(".multiboot") = MultibootHeader{};

export var stack_bytes: [32 * 1024]u8 align(16) linksection(".bss") = undefined;
const stack_bytes_slice = stack_bytes[0..];

export fn _start() callconv(.Naked) noreturn {
    asm volatile ("call kmain");
}

export fn kmain() void {
    tty.initialise();
    tty.write("Booting\n");

    var a: u8 = 5;
    var b: u8 = 6;
    a = asm volatile ("add %[num], %[num2]"
        : [ret] "={bl}" (-> u8),
        : [num] "{al}" (a),
          [num2] "{bl}" (b),
    );
    tty.printf("Sum {d}\n", .{a});

    inline for (0..4) |_| {
        tty.write("asd\n");
    }
    tty.printf("Test {d}\n", .{5});
    tty.printf("Test {d}\n", .{10});
    tty.write("a\rb\n");

    while (true) {
        io.write_u8(0x70, 0x00);
        const c = io.read_u8(0x71);
        if (c % 10 != 0) {
            tty.write("\r");
        }
        // tty.printf("RTC secs = {d}\n", .{c});
        tty.write("Loading");
        for (0..c) |_| {
            tty.write(".");
        }
    }

    while (true) {}
}
