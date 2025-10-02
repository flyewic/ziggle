const std = @import("std");
const PlayerModule = @import("player/player.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var allocator = gpa.allocator();
    var player = PlayerModule.Player.init("Johnny", &allocator);

    player.print();

    try player.level_up();
    try player.inventory.add(.{ .name = "Sword" });
    try player.inventory.add(.{ .name = "Potion" });
    player.print();

    try player.take_damage(20);
    player.print();

    try player.full_heal();
    player.print();

    try player.inventory.add(.{ .name = "Potion", .quantity = 5 });
    player.print();

    player.inventory.deinit();
}
