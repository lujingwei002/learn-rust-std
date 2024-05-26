# repr

## 基本用法

复合结构(`struct`，`enum`，`union`)都可以用`repr` attribute指定`layout`。可选的`repr`包括

- Rust (默认)
- C
- primitive representation
- transparent

不指定`repr`的话，默认是`repr(Rust)`

```rust
struct ThreeInts {
    first: i16,
    second: i8,
    third: i32
}
```

指定`repr(C)`

```rust
#[repr(C)]
struct ThreeInts {
    first: i16,
    second: i8,
    third: i32
}
```

`repr`可以改变结构中字段间的`padding`和结构本身的`alignment`，但不能改变结构字段的`layout`。

```rust
#[repr(C)]
struct ThreeInts {
    first: i16,
    second: i8,
    third: i32
}
struct Inner {
    first: i16,
    second: i8,
    third: i32
}
```

> `Inner`不受`#[repr(C)]`影响。

## repr(Rust)

`repr(Rust)`是默认的representation。

有三个特征

1. 每个字段properly aligned。
1. 字段不重叠。
1. 此类型最终的`alignment`等于字段中的`alignment`的最大值。

例如

```rust
struct A {
    a: u8,
    b: u32,
    c: u16,
}
```

对齐后，结构可能是

```rust
struct A {
    a: u8,
    _pad1: [u8; 3], // to align `b`
    b: u32,
    c: u16,
    _pad2: [u8; 2], // to make overall size multiple of 4
}

assert_eq!(std::mem::align_of::<A>(), 4);
assert_eq!(std::mem::size_of::<A>(), 12);
```



## repr(Rust)优化

`repr(Rust)`和`repr(C)`最大的区别就是编译器**可能会优化结构中的字段的顺序**，所以上例中的结构最终也可能是这样的

```rust
struct A {
    b: u32,
    c: u16,
    a: u8,
    _pad: u8,
}
assert_eq!(std::mem::align_of::<A>(), 4);
assert_eq!(std::mem::size_of::<A>(), 8);
```

`enum`中的`tag`字段也会被排序优化

```rust
enum Foo {
    A(u32),
    B(u64),
    C(u8),
}
```

最终可能是这样

```rust
struct FooRepr {
    data: u64, // this is either a u64, u32, or u8 based on `tag`
    tag: u8,   // 0 = A, 1 = B, 2 = C
}
```

## repr(C)

`repr(C)`可以用于`struct`，`union`，`enum`。

> 但不能用于`zero-variant enum`，将会报错.

## repr(C) struct

和`repc(Rust)`差不多，但不会改变字段间的顺序。

1. 每个字段properly aligned。
1. 字段不重叠。
1. 此类型最终的`alignment`等于字段中的`alignment`的最大值。

例如

```rust
struct A {
    b: u32,
    c: u16,
    a: u8,
}
```

最终是这样

```rust
struct A {
    b: u32,
    c: u16,
    a: u8,
    _pad: u8,
}
assert_eq!(std::mem::align_of::<A>(), 4);
assert_eq!(std::mem::size_of::<A>(), 8);
```

结构的算法如下

```rust
/// Returns the amount of padding needed after `offset` to ensure that the
/// following address will be aligned to `alignment`.
fn padding_needed_for(offset: usize, alignment: usize) -> usize {
    let misalignment = offset % alignment;
    if misalignment > 0 {
        // round up to next multiple of `alignment`
        alignment - misalignment
    } else {
        // already a multiple of `alignment`
        0
    }
}

struct.alignment = struct.fields().map(|field| field.alignment).max();

let current_offset = 0;

for field in struct.fields_in_declaration_order() {
    // Increase the current offset so that it's a multiple of the alignment
    // of this field. For the first field, this will always be zero.
    // The skipped bytes are called padding bytes.
    current_offset += padding_needed_for(current_offset, field.alignment);
    struct[field].offset = current_offset;
    current_offset += field.size;
}

struct.size = current_offset + padding_needed_for(current_offset, struct.alignment);
```

`layout`也有个`extend`方法可以用于计算

```rust
pub fn repr_c(fields: &[Layout]) -> Result<(Layout, Vec<usize>), LayoutError> {
    let mut offsets = Vec::new();
    let mut layout = Layout::from_size_align(0, 1)?;
    for &field in fields {
        let (new_layout, offset) = layout.extend(field)?;
        layout = new_layout;
        offsets.push(offset);
    }
    // Remember to finalize with `pad_to_align`!
    Ok((layout.pad_to_align(), offsets))
}
```

## repr(C) union

`repr(C)`用于`union`时有三个特征

- `union`的`alignment`等于结构中字段的`alignment`的最大值。
- `union`的`size`等于结构中字段的`size`的最大值。然后可能会增加`size`，使`size`是`alignment`的整数倍。
- `alignment`和`size`可以是来自不同的字段。

例如

```rust
#[repr(C)]
union Union {
    f1: u16,
    f2: [u8; 4],
}

assert_eq!(std::mem::size_of::<Union>(), 4);  // From f2
assert_eq!(std::mem::align_of::<Union>(), 2); // From f1

#[repr(C)]
union SizeRoundedUp {
   a: u32,
   b: [u16; 3],
}

assert_eq!(std::mem::size_of::<SizeRoundedUp>(), 8);  // Size of 6 from b,
                                                      // rounded up to 8 from
                                                      // alignment of a.
assert_eq!(std::mem::align_of::<SizeRoundedUp>(), 4); // From a

```

## repr(C) Field-less Enum

`repr(C)`用于`enum`时，使`enum`的`alignment`，`size`和c的一样。

例如

```rust
#[repr(C)]
enum Status {
    A,
    B,
    C,
}
fn main() {
    assert_eq!(std::mem::size_of::<Status>(), 4);
    assert_eq!(std::mem::align_of::<Status>(), 4);
}
```

## repr(C) Enum With Fields

例子

```rust
// This Enum has the same representation as ...
#[repr(C)]
enum MyEnum {
    A(u32),
    B(f32, u64),
    C { x: u32, y: u8 },
    D,
 }

// ... this struct.
#[repr(C)]
struct MyEnumRepr {
    tag: MyEnumDiscriminant,
    payload: MyEnumFields,
}

// This is the discriminant enum.
#[repr(C)]
enum MyEnumDiscriminant { A, B, C, D }

// This is the variant union.
#[repr(C)]
union MyEnumFields {
    A: MyAFields,
    B: MyBFields,
    C: MyCFields,
    D: MyDFields,
}

#[repr(C)]
#[derive(Copy, Clone)]
struct MyAFields(u32);

#[repr(C)]
#[derive(Copy, Clone)]
struct MyBFields(f32, u64);

#[repr(C)]
#[derive(Copy, Clone)]
struct MyCFields { x: u32, y: u8 }

// This struct could be omitted (it is a zero-sized type), and it must be in
// C/C++ headers.
#[repr(C)]
#[derive(Copy, Clone)]
struct MyDFields;

```



## 参考

- [Type layout - The Rust Reference (rust-lang.org)](https://doc.rust-lang.org/reference/type-layout.html)

- [repr(Rust) - The Rustonomicon (rust-lang.org)](https://doc.rust-lang.org/nomicon/repr-rust.html)

  
