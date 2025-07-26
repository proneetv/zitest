const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "rocksdb_example",
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("main.zig"),
    });

    exe.addIncludePath(.{ .cwd_relative = "/opt/homebrew/Cellar/rocksdb/10.4.2/include" });
    exe.addLibraryPath(.{ .cwd_relative = "/opt/homebrew/Cellar/rocksdb/10.4.2/lib" });

    exe.linkSystemLibrary("rocksdb");
    exe.linkSystemLibrary("snappy");
    exe.linkSystemLibrary("z");
    exe.linkSystemLibrary("bz2");
    exe.linkSystemLibrary("lz4");
    exe.linkSystemLibrary("pthread");

    exe.linkLibC();

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    b.step("run", "Run the program").dependOn(&run_cmd.step);
}
