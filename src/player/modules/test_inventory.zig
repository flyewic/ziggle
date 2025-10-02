const std = @import("std");
const InventoryModule = @import("inventory.zig");

test "adding and stacking items" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();

    var inv = InventoryModule.Inventory.init(&allocator);
    try inv.add(.{ .name = "Potion", .quantity = 1 });
    try inv.add(.{ .name = "Potion", .quantity = 2 });

    const potion = try inv.find("Potion");
    try std.testing.expect(potion.*.quantity == 3);

    inv.deinit();
}

test "overflowing quantity" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();

    var inv = InventoryModule.Inventory.init(&allocator);

    try inv.add(.{ .name = "Potion", .quantity = 200 });

    const err = inv.add(.{ .name = "Potion", .quantity = 100 }) catch |e| e;
    try std.testing.expect(err == InventoryModule.QuantityOverflow);

    inv.deinit();
}

test "removing items from empty inventory" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();

    var inv = InventoryModule.Inventory.init(&allocator);

    const err = inv.remove("NonexistentItem") catch |e| e;
    try std.testing.expect(err == InventoryModule.InventoryEmpty);

    inv.deinit();
}

test "removing item not found" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();

    var inv = InventoryModule.Inventory.init(&allocator);

    try inv.add(.{ .name = "Potion", .quantity = 1 });

    const err = inv.remove("Sword") catch |e| e;
    try std.testing.expect(err == InventoryModule.ItemNotFound);

    inv.deinit();
}

test "successful remove" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();

    var inv = InventoryModule.Inventory.init(&allocator);
    try inv.add(.{ .name = "Potion", .quantity = 1 });

    try inv.remove("Potion");

    const err = inv.find("Potion") catch |e| e;
    try std.testing.expect(err == InventoryModule.ItemNotFound or err == InventoryModule.InventoryEmpty);

    inv.deinit();
}
