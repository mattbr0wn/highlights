const std = @import("std");
const sqlite = @import("sqlite.zig");

pub fn main() !void {
    const db: *sqlite.c.sqlite3 = try sqlite.openDb("/Users/mbrown/src/github.com/mattbr0wn/highlights/KoboReader.sqlite");
    defer _ = sqlite.c.sqlite3_close(db);

    const sql: []const u8 = "SELECT ContentID, Text FROM Bookmark;";
    const stmt: *sqlite.c.sqlite3_stmt = try sqlite.prepareStatement(db, sql);
    defer _ = sqlite.c.sqlite3_finalize(stmt);

    try sqlite.executeQuery(stmt, processRow);
}

fn processRow(stmt: *sqlite.c.sqlite3_stmt) !void {
    const bookFile = std.mem.span(sqlite.c.sqlite3_column_text(stmt, 0));
    const highlight = std.mem.span(sqlite.c.sqlite3_column_text(stmt, 1));

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Book: {s}\n", .{parseBookFileName(bookFile)});
    try stdout.print("Highlight Text: {s}\n\n", .{highlight});
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
