const std = @import("std");
const c = @cImport({
    @cInclude("sqlite3.h");
});

pub fn main() !void {
    const db: *c.sqlite3 = try openDb("/Volumes/KOBOeReader/.kobo/KoboReader.sqlite");
    defer _ = c.sqlite3_close(db);
    std.debug.print("Opened DB", .{});

    const sql: []const u8 = "SELECT ContentID, Text FROM Bookmark;";
    const stmt: *c.sqlite3_stmt = try prepareStatement(db, sql);
    defer _ = c.sqlite3_finalize(stmt);

    try executeQuery(stmt);
}

fn openDb(path: []const u8) !*c.sqlite3 {
    var db: ?*c.sqlite3 = null;
    const rc = c.sqlite3_open(path.ptr, &db);
    if (rc != c.SQLITE_OK) {
        return error.OpenDatabaseFailed;
    }
    return db.?;
}

fn prepareStatement(db: *c.sqlite3, sql: []const u8) !*c.sqlite3_stmt {
    var stmt: ?*c.sqlite3_stmt = null;
    const rc = c.sqlite3_prepare_v2(db, sql.ptr, @intCast(sql.len), &stmt, null);
    if (rc != c.SQLITE_OK) {
        const err = c.sqlite3_errmsg(db);
        std.debug.print("Failed to prepare statemetn: {s}\n", .{err});
        return error.PrepareStatementFailed;
    }
    return stmt.?;
}

fn executeQuery(stmt: *c.sqlite3_stmt) !void {
    while (c.sqlite3_step(stmt) == c.SQLITE_ROW) {
        const bookTitle = std.mem.span(c.sqlite3_column_text(stmt, 0));
        const bookmarkText = std.mem.span(c.sqlite3_column_text(stmt, 1));

        std.debug.print("Book Title: {s}\n", .{bookTitle});
        std.debug.print("Highlight Text: {s}\n\n", .{bookmarkText});
    }
}
