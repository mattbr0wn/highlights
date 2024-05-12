const std = @import("std");
const sqlite = @import("sqlite.zig");
const books = @import("books.zig");

pub fn getHighlights(db: *sqlite.c.sqlite3, bookId: []const u8) !void {
    var buffer: [256]u8 = undefined;
    const sql = try std.fmt.bufPrint(&buffer, "SELECT VolumeID, Text FROM Bookmark WHERE VolumeID = '{s}';", .{bookId});

    const stmt: *sqlite.c.sqlite3_stmt = try sqlite.prepareStatement(db, sql);
    defer _ = sqlite.c.sqlite3_finalize(stmt);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("# {s}\n\n", .{books.parseBookFileName(bookId)});

    try sqlite.executeQuery(stmt, printHighlightsFromKobo);
}

pub fn getHighlightPath(buffer: *[256]u8, bookId: [*:0]u8) ![]const u8 {
    return std.fmt.bufPrint(buffer, "file:///mnt/onboard/{s}.kepub.epub", .{bookId});
}

fn printHighlightsFromKobo(stmt: *sqlite.c.sqlite3_stmt) !void {
    const highlight = std.mem.span(sqlite.c.sqlite3_column_text(stmt, 1));

    const stdout = std.io.getStdOut().writer();
    try stdout.print("{s}\n\n", .{highlight});
}
