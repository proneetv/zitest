const std = @import("std");
const rdb = @cImport({
    @cInclude("rocksdb/c.h");
});

pub fn main() !void {
    const db_name = "testdb";

    var err: [*c]u8 = null;

    const options = rdb.rocksdb_options_create();
    defer rdb.rocksdb_options_destroy(options);
    rdb.rocksdb_options_set_create_if_missing(options, 1);
    rdb.rocksdb_options_set_compression(options, rdb.rocksdb_snappy_compression);

    const db = rdb.rocksdb_open(options, db_name, &err);
    if (err != null) {
        std.debug.print("open error: {s}\n", .{err});
        rdb.rocksdb_free(err);
        return;
    }
    defer rdb.rocksdb_close(db);

    const wo = rdb.rocksdb_writeoptions_create();
    defer rdb.rocksdb_writeoptions_destroy(wo);

    const key = "name";
    const value = "foo";

    rdb.rocksdb_put(db, wo, key.ptr, key.len, value.ptr, value.len, &err);
    if (err != null) {
        std.debug.print("put error: {s}\n", .{err});
        rdb.rocksdb_free(err);
        return;
    }

    const ro = rdb.rocksdb_readoptions_create();
    defer rdb.rocksdb_readoptions_destroy(ro);

    var val_len: usize = 0;
    const val_ptr = rdb.rocksdb_get(db, ro, key.ptr, key.len, &val_len, &err);
    defer if (val_ptr != null) rdb.rocksdb_free(val_ptr);

    if (err != null) {
        std.debug.print("get error: {s}\n", .{err});
        rdb.rocksdb_free(err);
        return;
    }

    const val = val_ptr[0..val_len];
    std.debug.print("get key: {s}, len: {}, value: {s}\n", .{ key, val_len, val });
}
