#pragma once

#include <stdint.h>

using i8 = int8_t;
using i16 = int16_t;
using i32 = int32_t;
using i64 = int64_t;

using u8 = uint8_t;
using u16 = uint16_t;
using u32 = uint32_t;
using u64 = uint64_t;

using f32 = float;
using f64 = double;

using usize = uintptr_t;
using isize = intptr_t;

static_assert(sizeof(i8) == 1, "i8 size mismatch");
static_assert(sizeof(i16) == 2, "i16 size mismatch");
static_assert(sizeof(i32) == 4, "i32 size mismatch");
static_assert(sizeof(i64) == 8, "i64 size mismatch");

static_assert(sizeof(u8) == 1, "u8 size mismatch");
static_assert(sizeof(u16) == 2, "u16 size mismatch");
static_assert(sizeof(u32) == 4, "u32 size mismatch");
static_assert(sizeof(u64) == 8, "u64 size mismatch");

static_assert(sizeof(f32) == 4, "f32 size mismatch");
static_assert(sizeof(f64) == 8, "f64 size mismatch");
