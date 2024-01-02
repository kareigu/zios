pub inline fn write_u8(addr: u16, data: u8) void {
    asm volatile ("outb %[data], %[addr]"
        :
        : [data] "{al}" (data),
          [addr] "{dx}" (addr),
    );
}

pub inline fn read_u8(addr: u16) u8 {
    return asm volatile ("inb %[addr], %[ret]"
        : [ret] "={al}" (-> u8),
        : [addr] "{dx}" (addr),
    );
}
