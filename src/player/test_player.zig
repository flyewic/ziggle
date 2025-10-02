const std = @import("std");
const PlayerModule = @import("player.zig");

test "player initialization" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();

    const player = PlayerModule.Player.init("Test", &allocator);

    try std.testing.expectEqualStrings("Test", player.name);
    try std.testing.expect(player.health == 100);
    try std.testing.expect(player.level == 1);
    try std.testing.expect(player.inventory.max_slots == 16);
}

test "player takes damage and dies" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();

    var player = PlayerModule.Player.init("Test", &allocator);
    try player.take_damage(50);
    try std.testing.expect(player.health == 50);

    try player.take_damage(60);
    try std.testing.expect(player.health == 0);

    const err = player.take_damage(10) catch |e| e;
    try std.testing.expect(err == PlayerModule.PlayerDead);
}

test "player healing" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();

    var player = PlayerModule.Player.init("Test", &allocator);
    try player.take_damage(50);

    try player.heal(20);
    try std.testing.expect(player.health == 70);

    try player.heal(100);
    try std.testing.expect(player.health == player.max_health);

    const err = player.heal(10) catch |e| e;
    try std.testing.expect(err == PlayerModule.PlayerFullHealth);
}

test "player full heal" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();

    var player = PlayerModule.Player.init("Test", &allocator);
    try player.take_damage(99);
    try std.testing.expect(player.health == 1);

    try player.full_heal();
    try std.testing.expect(player.health == player.max_health);

    const err = player.full_heal() catch |e| e;
    try std.testing.expect(err == PlayerModule.PlayerFullHealth);
}

test "player earns and spends gold" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();

    var player = PlayerModule.Player.init("Test", &allocator);

    player.earn_gold(50);
    try std.testing.expect(player.gold == 50);

    try player.take_gold(20);
    try std.testing.expect(player.gold == 30);

    const err1 = player.take_gold(100) catch |e| e;
    try std.testing.expect(err1 == PlayerModule.PlayerNotEnoughGold);

    try player.take_gold(30);
    try std.testing.expect(player.gold == 0);

    const err2 = player.take_gold(1) catch |e| e;
    try std.testing.expect(err2 == PlayerModule.PlayerNoGold);
}

test "player levels up" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();

    var player = PlayerModule.Player.init("Test", &allocator);

    const old_slots = player.inventory.max_slots;
    try player.level_up();

    try std.testing.expect(player.level == 2);
    try std.testing.expect(player.max_health == 150);
    try std.testing.expect(player.health == 150);
    try std.testing.expect(player.inventory.max_slots == old_slots + 2);
}
