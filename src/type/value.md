# 值类型



Cell虽然也可以包裹指针类型，但Cell关注的是指针的值，而并不是指针指向的值。比如

```rust
use std::cell::*;
fn main() {
    let arr = 1;
    let a: Cell<&i32> = Cell::new(&arr);
}
```

而且Cell实现的CoerceUnsized是

```rust
impl<T: CoerceUnsized<U>, U> CoerceUnsized<Cell<U>> for Cell<T> {}
```

而不是

```rust
impl<T: Unsize<U>, U> CoerceUnsized<Cell<U>> for Cell<T> {}
```

即Cell可以转换 Cell<&[T; N]>到Cell<&[T]>，而不是 Cell<[T; N]>到Cell<[T]>。但Box却可以Box<[T; N]>到Box<[T]>，因为Box是指针类型。



