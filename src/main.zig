const std = @import("std");
const sqlite = @import("sqlite.zig");
const books = @import("books.zig");
const hl = @import("highlights.zig");

pub fn main() !void {
    const argv = std.os.argv;

    // open Database
    const dbPath: []const u8 = "/Users/mbrown/src/github.com/mattbr0wn/highlights/KoboReader.sqlite";
    const db: *sqlite.c.sqlite3 = try sqlite.openDb(dbPath);
    defer _ = sqlite.c.sqlite3_close(db);

    switch (argv.len) {
        1 => try books.getBooksWithHighlights(db),
        2 => {
            var buffer: [256]u8 = undefined;
            const bookId: []const u8 = try hl.getHighlightPath(&buffer, argv[1]);
            try hl.getHighlights(db, bookId);
        },
        else => std.debug.print("Usage: {s} [book]\n", .{argv[0]}),
    }
}
