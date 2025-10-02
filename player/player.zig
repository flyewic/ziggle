const std = @import("std");
const InventoryModule = @import("modules/inventory.zig");

pub const PlayerDead = error.PlayerDead;
pub const PlayerFullHealth = error.PlayerFullHealth;

const line = "==============================\n";
const subline = "------------------------------\n";

pub const Player = struct {
    name: []const u8,
    health: u32,
    max_health: u32,
    level: u16,
    inventory: InventoryModule.Inventory,

    pub fn init(name: []const u8, allocator: *std.mem.Allocator) Player {
        return Player{
            .name = name,
            .health = 100,
            .max_health = 100,
            .level = 1,
            .inventory = InventoryModule.Inventory.init(allocator),
        };
    }

    pub fn level_up(self: *Player) !void {
        self.level += 1;
        self.max_health += 50;
        self.health = self.max_health;
        self.inventory.max_slots += 2;
    }

    pub fn take_damage(self: *Player, amount: u32) !void {
        if (self.health == 0) {
            return PlayerDead;
        }

        if (self.health < amount) {
            self.health = 0;
            return;
        }

        self.health -= amount;
    }

    pub fn heal(self: *Player, amount: u32) !void {
        if (self.health == self.max_health) {
            return PlayerFullHealth;
        }

        if (self.health + amount > self.max_health) {
            self.health = self.max_health();
        }

        self.health += amount;
    }

    pub fn full_heal(self: *Player) !void {
        if (self.health == self.max_health) {
            return PlayerFullHealth;
        }

        self.health = self.max_health;
    }

    pub fn print(self: *Player) void {
        std.debug.print(line, .{});

        std.debug.print("Player: {s}\n", .{self.name});
        std.debug.print("Level: {}\n", .{self.level});
        std.debug.print("Health: {}/{}\n", .{ self.health, self.max_health });
        std.debug.print("Inventory ({}/{} items):\n", .{ self.inventory.used_slots, self.inventory.max_slots });

        var current = self.inventory.head;
        var i: usize = 0;
        while (current) |node| {
            std.debug.print("  {}: {s}\n", .{ i, node.item.name });
            current = node.next;
            i += 1;
        }

        std.debug.print(subline, .{});
    }
};
