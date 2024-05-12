const std = @import("std");
const sqlite = @import("sqlite.zig");

pub fn getBooksWithHighlights(db: *sqlite.c.sqlite3) !void {
    const sql: []const u8 = "SELECT DISTINCT VolumeID FROM Bookmark;";

    const stmt: *sqlite.c.sqlite3_stmt = try sqlite.prepareStatement(db, sql);
    defer _ = sqlite.c.sqlite3_finalize(stmt);

    try sqlite.executeQuery(stmt, getBooksFromKobo);
}

pub fn parseBookFileName(bookFile: []const u8) []const u8 {
    const lastSlashIndex = std.mem.lastIndexOf(u8, bookFile, "/") orelse return "";
    const dotIndex = std.mem.indexOfPos(u8, bookFile, lastSlashIndex + 1, ".") orelse bookFile.len;
    return bookFile[lastSlashIndex + 1 .. dotIndex];
}

fn getBooksFromKobo(stmt: *sqlite.c.sqlite3_stmt) !void {
    const filePath = std.mem.span(sqlite.c.sqlite3_column_text(stmt, 0));

    const stdout = std.io.getStdOut().writer();
    try stdout.print("{s}\n", .{parseBookFileName(filePath)});
}
