const std = @import("std");
const testing = std.testing;

fn Stack(comptime T: type) type {
    const ListNode = struct {
        const Self = @This();

        value: T,

        next: ?*Self,
    };

    return struct {
        const Self = @This();

        head: ?*ListNode,
        alloc: std.mem.Allocator,

        fn init(alloc: std.mem.Allocator) Self {
            return .{
                .alloc = alloc,
                .head = null,
            };
        }

        fn push(self: *Self, value: T) !void {
            var node = try self.alloc.create(ListNode);
            node.value = value;

            const head = self.head;
            node.next = head;
            self.head = node;
        }

        fn pop(self: *Self) ?T {
            if (self.head) |head| {
                self.head = head.next;
                const value = head.value;

                self.alloc.destroy(head);

                return value;
            }

            return null;
        }

        fn print(self: *Self) void {
            var curr = self.head;
            std.log.info("stack", .{});
            while (curr) |node| {
                std.log.info("-> {d}", .{node.value});

                curr = node.next;
            }
        }
    };
}

const IntStack = Stack(i32);

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var stack = IntStack.init(allocator);

    try stack.push(123);
    stack.print();
    try stack.push(322);
    stack.print();
    if (stack.pop()) |v| {
        std.log.info("POP RESULT {d}", .{v});
    }
    stack.print();
}