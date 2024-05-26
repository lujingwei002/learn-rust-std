# alignment

## 定义

|enum|移位|值|mark|-|
|-|-|-|-|-|
|Alignment::_Align1Shl0|1<<0|0b0001|0b0000|8字节对齐|
|Alignment::_Align1Shl1|1<<1|0b0010|0b0001|16字节对齐|
|Alignment::_Align1Shl2|1<<2|0b0100|0b0011|32字节对齐|
|Alignment::_Align1Shl3|1<<3|0b1000|0b0111|64字节对齐|
|Alignment::_Align1Shl...|1<<...|...|...|...|

最小是`Alignment::_Align1Shl0`，8字节对齐。

## 对齐对应的最大大小
```rust
const fn max_size_for_align(align: Alignment) -> usize {
    isize::MAX as usize - (align.as_usize() - 1)
}

```
## dangling

指针可以是`dangling`的，但需要对齐。可以用于`zst`对象或者`not yet initialized`状态。

```rust
 pub const fn dangling() -> Self {
    unsafe {
        let ptr = crate::ptr::invalid_mut::<T>(mem::align_of::<T>());
        NonNull::new_unchecked(ptr)
    }
}
```


## bitpacked
由于指针是4字节或者8字节对齐的，所有低位有几位是0
在`std/io/error/repr_bitpacked.rs`中用到这个特性来将指针打包成整数，并增加一些额外信息在低位。
宽度是64位是使用
```rust
#[cfg(all(target_pointer_width = "64", not(target_os = "uefi")))]
mod repr_bitpacked;
#[cfg(all(target_pointer_width = "64", not(target_os = "uefi")))]
use repr_bitpacked::Repr;

#[cfg(any(not(target_pointer_width = "64"), target_os = "uefi"))]
mod repr_unpacked;
#[cfg(any(not(target_pointer_width = "64"), target_os = "uefi"))]
use repr_unpacked::Repr;
```

```rust
pub(super) struct Repr(NonNull<()>, PhantomData<ErrorData<Box<Custom>>>);

impl Repr {
    pub(super) fn new_custom(b: Box<Custom>) -> Self {
        let p = Box::into_raw(b).cast::<u8>();
        // Should only be possible if an allocator handed out a pointer with
        // wrong alignment.
        debug_assert_eq!(p.addr() & TAG_MASK, 0);
        // Note: We know `TAG_CUSTOM <= size_of::<Custom>()` (static_assert at
        // end of file), and both the start and end of the expression must be
        // valid without address space wraparound due to `Box`'s semantics.
        //
        // This means it would be correct to implement this using `ptr::add`
        // (rather than `ptr::wrapping_add`), but it's unclear this would give
        // any benefit, so we just use `wrapping_add` instead.
        let tagged = p.wrapping_add(TAG_CUSTOM).cast::<()>();
        // Safety: `TAG_CUSTOM + p` is the same as `TAG_CUSTOM | p`,
        // because `p`'s alignment means it isn't allowed to have any of the
        // `TAG_BITS` set (you can verify that addition and bitwise-or are the
        // same when the operands have no bits in common using a truth table).
        //
        // Then, `TAG_CUSTOM | p` is not zero, as that would require
        // `TAG_CUSTOM` and `p` both be zero, and neither is (as `p` came from a
        // box, and `TAG_CUSTOM` just... isn't zero -- it's `0b01`). Therefore,
        // `TAG_CUSTOM + p` isn't zero and so `tagged` can't be, and the
        // `new_unchecked` is safe.
        let res = Self(unsafe { NonNull::new_unchecked(tagged) }, PhantomData);
        // quickly smoke-check we encoded the right thing (This generally will
        // only run in std's tests, unless the user uses -Zbuild-std)
        debug_assert!(matches!(res.data(), ErrorData::Custom(_)), "repr(custom) encoding failed");
        res
    }
    pub(super) fn new_os(code: RawOsError) -> Self {
        let utagged = ((code as usize) << 32) | TAG_OS;
        // Safety: `TAG_OS` is not zero, so the result of the `|` is not 0.
        let res = Self(unsafe { NonNull::new_unchecked(ptr::invalid_mut(utagged)) }, PhantomData);
        // quickly smoke-check we encoded the right thing (This generally will
        // only run in std's tests, unless the user uses -Zbuild-std)
        debug_assert!(
            matches!(res.data(), ErrorData::Os(c) if c == code),
            "repr(os) encoding failed for {code}"
        );
        res
    }
    pub(super) fn new_simple(kind: ErrorKind) -> Self {
        let utagged = ((kind as usize) << 32) | TAG_SIMPLE;
        // Safety: `TAG_SIMPLE` is not zero, so the result of the `|` is not 0.
        let res = Self(unsafe { NonNull::new_unchecked(ptr::invalid_mut(utagged)) }, PhantomData);
        // quickly smoke-check we encoded the right thing (This generally will
        // only run in std's tests, unless the user uses -Zbuild-std)
        debug_assert!(
            matches!(res.data(), ErrorData::Simple(k) if k == kind),
            "repr(simple) encoding failed {:?}",
            kind,
        );
        res
    }
}
```
`new_custom`将`tag`放在指针地址的低2位。