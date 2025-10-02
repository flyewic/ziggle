const std = @import("std");

pub const InventoryFull = error.InventoryFull;
pub const InventoryEmpty = error.InventoryEmpty;
pub const ItemNotFound = error.ItemNotFound;
pub const QuantityOverflow = error.QuantityOverflow;

const Item = struct {
    name: []const u8,
    quantity: u16 = 1,
};

const Node = struct {
    item: Item,
    next: ?*Node,
};

pub const Inventory = struct {
    max_slots: usize = 16,
    used_slots: usize = 0,
    head: ?*Node = null,
    allocator: *std.mem.Allocator,

    pub fn init(allocator: *std.mem.Allocator) Inventory {
        return Inventory{
            .max_slots = 16,
            .used_slots = 0,
            .head = null,
            .allocator = allocator,
        };
    }

    pub fn add(self: *Inventory, item: Item) !void {
        if (self.used_slots == self.max_slots) return InventoryFull;

        const existing_item: ?*Item = self.find(item.name) catch |err|
            if (err == ItemNotFound or err == InventoryEmpty) null else return err;

        if (existing_item) |it| {
            if (it.quantity + item.quantity > 255) return QuantityOverflow;
            it.quantity += item.quantity;
            return;
        }

        const new_node = try self.allocator.create(Node);
        new_node.* = Node{ .item = item, .next = self.head };
        self.head = new_node;
        self.used_slots += 1;
    }

    pub fn remove(self: *Inventory, item_name: []const u8) !void {
        if (self.used_slots == 0) return InventoryEmpty;

        var prev: ?*Node = null;
        var current = self.head;

        while (current) |node| {
            if (std.mem.eql(u8, node.item.name, item_name)) {
                if (prev) |p| {
                    p.next = node.next;
                } else {
                    self.head = node.next;
                }
                self.allocator.destroy(node);
                self.used_slots -= 1;
                return;
            }
            prev = current;
            current = node.next;
        }

        return ItemNotFound;
    }

    pub fn find(self: *Inventory, item_name: []const u8) !*Item {
        if (self.used_slots == 0) return InventoryEmpty;

        var current = self.head;
        while (current) |node| {
            if (std.mem.eql(u8, node.item.name, item_name)) {
                return &node.item;
            }
            current = node.next;
        }

        return ItemNotFound;
    }

    pub fn print(self: *Inventory) void {
        if (self.used_slots == 0) {
            std.debug.print("Inventory is empty.\n", .{});
            return;
        }

        var current = self.head;
        var i: usize = 0;

        while (current) |node| {
            std.debug.print("  {}: {}x {s}\n", .{ i, node.item.quantity, node.item.name });
            current = node.next;
            i += 1;
        }
    }

    pub fn deinit(self: *Inventory) void {
        var current = self.head;
        while (current) |node| {
            const next = node.next;
            self.allocator.destroy(node);
            current = next;
        }

        self.head = null;
    }
};
