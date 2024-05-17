const std = @import("std");
const sqlite = @import("sqlite.zig");
const books = @import("books.zig");

pub fn getHighlights(db: *sqlite.c.sqlite3, bookId: [:0]u8) !void {
    var bookBuf: [256]u8 = undefined;
    var sqlBuf: [256]u8 = undefined;

    const book = try getHighlightPath(&bookBuf, bookId);
    const sql = try getHighlightSql(&sqlBuf, book);

    const stmt: *sqlite.c.sqlite3_stmt = try sqlite.prepareStatement(db, sql);
    defer _ = sqlite.c.sqlite3_finalize(stmt);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("# {s}\n\n", .{books.parseBookFileName(book)});

    try sqlite.executeQuery(stmt, printHighlightsFromKobo);
}

fn getHighlightSql(buffer: *[256]u8, bookId: []const u8) ![]const u8 {
    return std.fmt.bufPrint(buffer[0..], "select volumeid, text from bookmark where volumeid = '{s}';", .{bookId});
}

fn getHighlightPath(buffer: *[256]u8, bookId: [:0]u8) ![]const u8 {
    return std.fmt.bufPrint(buffer[0..], "file:///mnt/onboard/{s}.kepub.epub", .{bookId});
}

fn printHighlightsFromKobo(stmt: *sqlite.c.sqlite3_stmt) !void {
    const highlight = std.mem.span(sqlite.c.sqlite3_column_text(stmt, 1));

    const stdout = std.io.getStdOut().writer();
    try stdout.print("{s}\n\n", .{highlight});
}
