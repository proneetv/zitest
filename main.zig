const std = @import("std");
const c = @cImport({
    @cInclude("rocksdb/c.h");
});

pub fn main() !void {
    const db_name = "testdb";

    var err: [*c]u8 = null;

    const options = c.rocksdb_options_create();
    defer c.rocksdb_options_destroy(options);
    c.rocksdb_options_set_create_if_missing(options, 1);
    c.rocksdb_options_set_error_if_exists(options, 1);
    c.rocksdb_options_set_compression(options, c.rocksdb_snappy_compression);

    const db = c.rocksdb_open(options, db_name, &err);
    if (err != null) {
        std.debug.print("open error: {s}\n", .{err});
        c.rocksdb_free(err);
        return;
    }
    defer c.rocksdb_close(db);

    const wo = c.rocksdb_writeoptions_create();
    defer c.rocksdb_writeoptions_destroy(wo);

    const key = "name";
    const value = "foo";

    c.rocksdb_put(db, wo, key.ptr, key.len, value.ptr, value.len, &err);
    if (err != null) {
        std.debug.print("put error: {s}\n", .{err});
        c.rocksdb_free(err);
        return;
    }

    const ro = c.rocksdb_readoptions_create();
    defer c.rocksdb_readoptions_destroy(ro);

    var val_len: usize = 0;
    const val_ptr = c.rocksdb_get(db, ro, key.ptr, key.len, &val_len, &err);
    defer if (val_ptr != null) c.rocksdb_free(val_ptr);

    if (err != null) {
        std.debug.print("get error: {s}\n", .{err});
        c.rocksdb_free(err);
        return;
    }

    const val = val_ptr[0..val_len];
    std.debug.print("get key len: {}, value: {s}\n", .{ val_len, val });
}
