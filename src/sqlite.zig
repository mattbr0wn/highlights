const std = @import("std");
pub const c = @cImport({
    @cInclude("sqlite3.h");
});

pub fn openDb(path: []const u8) !*c.sqlite3 {
    var db: ?*c.sqlite3 = null;
    const rc = c.sqlite3_open(path.ptr, &db);
    if (rc != c.SQLITE_OK) {
        return error.OpenDatabaseFailed;
    }
    return db.?;
}

pub fn prepareStatement(db: *c.sqlite3, sql: []const u8) !*c.sqlite3_stmt {
    var stmt: ?*c.sqlite3_stmt = null;
    const rc = c.sqlite3_prepare_v2(db, sql.ptr, @intCast(sql.len), &stmt, null);
    if (rc != c.SQLITE_OK) {
        const err = c.sqlite3_errmsg(db);
        std.debug.print("Failed to prepare statement: {s}\n", .{err});
        return error.PrepareStatementFailed;
    }
    return stmt.?;
}

pub fn executeQuery(stmt: *c.sqlite3_stmt, callback: anytype) !void {
    while (c.sqlite3_step(stmt) == c.SQLITE_ROW) {
        try callback(stmt);
    }
}
