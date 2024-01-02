var SYS_TIMER_FRAC: u32 = 1;
var SYS_TIMER_MS: u32 = 1;
var IRQ0_FRAC: u32 = 1;
var IRQ0_MS: u32 = 1;
var IRQ0_FREQ: u32 = 1;
var PIT_RELOAD_VAL: u16 = 1;

fn IRQ0_handler() void {
    SYS_TIMER_FRAC += IRQ0_FRAC;
    SYS_TIMER_MS += IRQ0_MS;

    asm volatile ("mov %0x20, %al");
    asm volatile ("out %al, %0x20");
}

fn PIT_init(freq: u32) void {
    _ = freq;
}
