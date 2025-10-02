const std = @import("std");
const InventoryModule = @import("inventory.zig");

pub const Player = struct {
    name: []const u8,
    health: u32,
    maxHealth: u32,
    level: u16,
    inventory: InventoryModule.Inventory,

    pub fn init(name: []const u8, allocator: *std.mem.Allocator) Player {
        return Player{
            .name = name,
            .health = 100,
            .maxHealth = 100,
            .level = 1,
            .inventory = InventoryModule.Inventory.init(allocator),
        };
    }

    pub fn level_up(self: *Player) !void {
        self.level += 1;
        self.maxHealth += 50;
        self.health = self.maxHealth;
        self.inventory.max_slots += 2;
    }

    pub fn print(self: *Player) void {
        std.debug.print("Player: {s}\n", .{self.name});
        std.debug.print("Level: {}\n", .{self.level});
        std.debug.print("Health: {}/{}\n", .{ self.health, self.maxHealth });
        std.debug.print("Inventory ({}/{} items):\n", .{ self.inventory.used_slots, self.inventory.max_slots });

        var current = self.inventory.head;
        var i: usize = 0;
        while (current) |node| {
            std.debug.print("  {}: {s}\n", .{ i, node.item.name });
            current = node.next;
            i += 1;
        }
    }
};
