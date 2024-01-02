const std = @import("std");

pub fn build(b: *std.Build) !void {
    const kernel = try build_kernel(b);
    const run_cmd = b.addSystemCommand(&[_][]const u8{
        "qemu-system-i386",
        "-kernel",
        kernel,
        // "-machine",
        // "type=pc-i440fx-3.1",
    });
    run_cmd.step.dependOn(b.default_step);

    const run = b.step("run", "Run in qemu");
    run.dependOn(&run_cmd.step);
}

fn build_kernel(b: *std.Build) ![]const u8 {
    const kernel = b.addExecutable(.{
        .name = "kernel",
        .root_source_file = .{ .path = "src/kernel.zig" },
        .optimize = b.standardOptimizeOption(.{}),
        .target = b.standardTargetOptions(.{ .default_target = .{
            .cpu_arch = .x86,
            .os_tag = .freestanding,
            .abi = .none,
        } }),
    });
    kernel.setLinkerScript(.{ .path = "src/linker.ld" });
    kernel.code_model = .kernel;
    kernel.build_id = .none;

    b.default_step.dependOn(&kernel.step);
    b.installArtifact(kernel);
    return try std.mem.join(b.allocator, "/", &[_][]const u8{ b.install_path, "bin", "kernel" });
}
