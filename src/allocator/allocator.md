# allocator

## 为什么需要`Allocator`

`Allocator`的代码

```rust
pub unsafe trait Allocator {
    fn allocate(&self, layout: Layout) -> Result<NonNull<[u8]>, AllocError>;
    fn allocate_zeroed(&self, layout: Layout) -> Result<NonNull<[u8]>, AllocError>;
    unsafe fn deallocate(&self, ptr: NonNull<u8>, layout: Layout);
    unsafe fn grow(
        &self,
        ptr: NonNull<u8>,
        old_layout: Layout,
        new_layout: Layout,
    ) -> Result<NonNull<[u8]>, AllocError>;
    unsafe fn grow_zeroed(
        &self,
        ptr: NonNull<u8>,
        old_layout: Layout,
        new_layout: Layout,
    ) -> Result<NonNull<[u8]>, AllocError>;
    unsafe fn shrink(
        &self,
        ptr: NonNull<u8>,
        old_layout: Layout,
        new_layout: Layout,
    ) -> Result<NonNull<[u8]>, AllocError>;
    fn by_ref(&self) -> &Self;
}
```

看起来和`GlobalAlloc`差不多，先看一下`Allocator`和`GlobalAlloc`的区别

- `Allocator`是为`ZST`，`reference`, `smart pointer`设计的。
- `copying`，`cloning`，`moving` `allocator`都不能破坏`allocator`内部的`memory block`，`copied`和`cloned`出来的`allocator`的行为要和原来的一致。

# `ZST`
即`layout`的大小可以是0，但是也需要对齐的。
看一下`alloc crate`中`Global`的实现
```rust
impl Global {
    #[inline]
    fn alloc_impl(&self, layout: Layout, zeroed: bool) -> Result<NonNull<[u8]>, AllocError> {
        match layout.size() {
            0 => Ok(NonNull::slice_from_raw_parts(layout.dangling(), 0)),
            // SAFETY: `layout` is non-zero in size,
            size => unsafe {
                let raw_ptr = if zeroed { alloc_zeroed(layout) } else { alloc(layout) };
                let ptr = NonNull::new(raw_ptr).ok_or(AllocError)?;
                Ok(NonNull::slice_from_raw_parts(ptr, size))
            },
        }
    }
}
unsafe impl Allocator for Global {
    #[inline]
    fn allocate(&self, layout: Layout) -> Result<NonNull<[u8]>, AllocError> {
        self.alloc_impl(layout, false)
    }
}
```
可以看到直接返回`dangling`指针就可以了。

# `smart point`
先看一下`RawVec`的实现，`RawVec`其实是指针和`allocator`的打包，`RawVec`释放和复制时都需要用到对应的`allocator`。
```rust
pub(crate) struct RawVec<T, A: Allocator = Global> {
    ptr: Unique<T>,
    cap: usize,
    alloc: A,
}
```
因此`allocator`还要满足另外一个条件，就是移动，复制，克隆时后的对象的行为要和原来的一致。