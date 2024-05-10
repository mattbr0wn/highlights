const std = @import("std");
const c = @cImport({
    @cInclude("sqlite3.h");
});

pub fn main() !void {
    const db: *c.sqlite3 = try openDb("/Users/mbrown/src/github.com/mattbr0wn/highlights/KoboReader.sqlite");
    defer _ = c.sqlite3_close(db);

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

fn parseBookFileName(bookFile: []const u8) []const u8 {
    const firstSlashIndex = std.mem.indexOf(u8, bookFile, "/");
    const secondSlashIndex = if (firstSlashIndex) |index| std.mem.indexOfPos(u8, bookFile, index + 1, "/") else null;
    const thirdSlashIndex = if (secondSlashIndex) |index| std.mem.indexOfPos(u8, bookFile, index + 1, "/") else null;

    if (firstSlashIndex != null and secondSlashIndex != null and secondSlashIndex.? > firstSlashIndex.?) {
        const dotIndex = std.mem.indexOfPos(u8, bookFile, thirdSlashIndex.?, ".") orelse bookFile.len;
        return bookFile[thirdSlashIndex.? + 1 .. dotIndex];
    } else {
        return "";
    }
}

fn executeQuery(stmt: *c.sqlite3_stmt) !void {
    while (c.sqlite3_step(stmt) == c.SQLITE_ROW) {
        const bookFile = std.mem.span(c.sqlite3_column_text(stmt, 0));
        const highlight = std.mem.span(c.sqlite3_column_text(stmt, 1));

        const stdout = std.io.getStdOut().writer();

        try stdout.print("Book: {s}\n", .{parseBookFileName(bookFile)});
        try stdout.print("Highlight Text: {s}\n\n", .{highlight});
    }
}
