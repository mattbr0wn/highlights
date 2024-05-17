const std = @import("std");
const sqlite = @import("sqlite.zig");
const books = @import("books.zig");
const hl = @import("highlights.zig");

const Command = enum {
    List,
    Get,
    Help,
};

pub fn main() !void {
    // Get cmd line args
    var buffer: [512]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(buffer[0..]);
    const allocator = fba.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // open Database
    const dbPath: []const u8 = "/Users/mbrown/src/github.com/mattbr0wn/klip/KoboReader.sqlite";
    const db: *sqlite.c.sqlite3 = try sqlite.openDb(dbPath);
    defer _ = sqlite.c.sqlite3_close(db);

    if (args.len < 2) {
        helpCmd();
        return;
    }

    const cmd: Command = parseCommand(args[1]);

    switch (cmd) {
        Command.List => try books.getBooksWithHighlights(db),
        Command.Get => {
            try hl.getHighlights(db, args[2]);
        },
        else => helpCmd(),
    }
}

fn parseCommand(arg: []const u8) Command {
    if (std.mem.eql(u8, arg, "ls")) {
        return Command.List;
    } else if (std.mem.eql(u8, arg, "get")) {
        return Command.Get;
    } else {
        return Command.Help;
    }
}

fn helpCmd() void {
    std.debug.print(
        \\Usage: klip <command>
        \\
        \\Commands:
        \\
        \\  get     [book_name]     Retrieves highlights for a given book
        \\  ls                      Returns a list of books with highlights
        \\
    , .{});
}
