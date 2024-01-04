# rawvec



## 速览

- RawVec是在堆中申请的一段连续的内存，结构为数组，但长度可以增长或者收缩。

- RawVec的内存是末初化的状态，因此不用`drop`元素。

- RawVec内部保存着内存起始地址和申请此内存的`allocator`。

  

## 申请内存

申请0长度的内存

```rust
impl<T, A: Allocator> RawVec<T, A> {
    pub const fn new_in(alloc: A) -> Self {
        Self { ptr: Unique::dangling(), cap: 0, alloc }
    }
}
```

## 增长内存

内存增长有两种策略，一种是指定增加的长度，一种是以2倍的速度增加。

```rust
fn grow_amortized(&mut self, len: usize, additional: usize) -> Result<(), TryReserveError> {
    debug_assert!(additional > 0);

    if T::IS_ZST {
        return Err(CapacityOverflow.into());
    }

    let required_cap = len.checked_add(additional).ok_or(CapacityOverflow)?;

    let cap = cmp::max(self.cap * 2, required_cap);
    let cap = cmp::max(Self::MIN_NON_ZERO_CAP, cap);

    let new_layout = Layout::array::<T>(cap);

    let ptr = finish_grow(new_layout, self.current_memory(), &mut self.alloc)?;
    self.set_ptr_and_cap(ptr, cap);
    Ok(())
}
```

下面是指定长度的情况

```rust
fn grow_exact(&mut self, len: usize, additional: usize) -> Result<(), TryReserveError> {
    if T::IS_ZST {
        return Err(CapacityOverflow.into());
    }

    let cap = len.checked_add(additional).ok_or(CapacityOverflow)?;
    let new_layout = Layout::array::<T>(cap);

    let ptr = finish_grow(new_layout, self.current_memory(), &mut self.alloc)?;
    self.set_ptr_and_cap(ptr, cap);
    Ok(())
}
```



## shrink



## 转为Box

```rust
pub unsafe fn into_box(self, len: usize) -> Box<[MaybeUninit<T>], A> {
    debug_assert!(
        len <= self.capacity(),
        "`len` must be smaller than or equal to `self.capacity()`"
    );
    let me = ManuallyDrop::new(self);
    unsafe {
        let slice = slice::from_raw_parts_mut(me.ptr() as *mut MaybeUninit<T>, len);
        Box::from_raw_in(slice, ptr::read(&me.alloc))
    }
}
```

## drop

drop的时候释放内存，但不需要调用元素的drop。

```rust
unsafe impl<#[may_dangle] T, A: Allocator> Drop for RawVec<T, A> {
    fn drop(&mut self) {
        if let Some((ptr, layout)) = self.current_memory() {
            unsafe { self.alloc.deallocate(ptr, layout) }
        }
    }
}
```

