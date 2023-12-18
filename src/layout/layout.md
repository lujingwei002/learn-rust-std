# layout

## 定义
`Layout`是`size`和`align`的组合，`well-align`是指`size`是`align`的整数倍。
```rust
pub struct Layout {
    size: usize,
    align: Alignment,
}
```

## `[u8;10]`
数组，占用10个字节

## `[u8]`
也是数组，但长度不固定，只能在堆中。

## `&[u8]`
切片，胖指针，占16个字节，一个是数组地址，一个是数组长度

## `str`
其实就是`[u8]`，`!Sized`。

## `&str`
其实就是`&[u8]`

## `dyn Any`
特征对象，`!Sized`。

## `&dyn Any`
胖指针，占16字节，一个是指向对象地址，一个是指向`VTable`

## `VTable`
- 对象的大小，和`slice`类似，`slice`保存的是数组的长度。
- alignment
- `drop`的实现。
- 实现这个特征的实现（函数表）


## `*const i32`
8字节

## `*const [u8]`
16字节

## `&i32`
8字节

## `&[u8]`
16字节