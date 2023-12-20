# cmp

## 重点

- 满足`BytewiseEq`特征的元素，可以直接用`compare_byte`判断是否相等。
- 元素类型是`u8`的话，可以直接用`compare_byte`比较大小。
- 元素类型是`i8`,`u8`的话，可以用`memchr`查找。

## AlwaysApplicableOrd有什么用的？

```rust
#[stable(feature = "rust1", since = "1.0.0")]
impl<T: Ord> Ord for [T] {
    fn cmp(&self, other: &[T]) -> Ordering {
        SliceOrd::compare(self, other)
    }
}

/// Implements comparison of vectors [lexicographically](Ord#lexicographical-comparison).
#[stable(feature = "rust1", since = "1.0.0")]
impl<T: PartialOrd> PartialOrd for [T] {
    fn partial_cmp(&self, other: &[T]) -> Option<Ordering> {
        SlicePartialOrd::partial_compare(self, other)
    }
}

// This is the impl that we would like to have. Unfortunately it's not sound.
// See `partial_ord_slice.rs`.
/*
impl<A> SlicePartialOrd for A
where
    A: Ord,
{
    default fn partial_compare(left: &[A], right: &[A]) -> Option<Ordering> {
        Some(SliceOrd::compare(left, right))
    }
}
*/
impl<A: AlwaysApplicableOrd> SlicePartialOrd for A {
    fn partial_compare(left: &[A], right: &[A]) -> Option<Ordering> {
        Some(SliceOrd::compare(left, right))
    }
}
```

这段代码目的主要是用`SliceOrd::compare`去实现`partial_compare`方法。因为`Ord`是继承`PartialOrd`特征的，而且还需要重复实现`partial_cmp`方法，因此对于T满足`Ord`接口的话，可以直接用`SliceOrd::compare`去比较。但上面注释也提到了，`A:Ord`没有效果，因此引入了`AlwaysApplicableOrd`特征。

## PartialEq的特化

```rust
trait SlicePartialEq<B> {
    fn equal(&self, other: &[B]) -> bool;

    fn not_equal(&self, other: &[B]) -> bool {
        !self.equal(other)
    }
}

// Generic slice equality
impl<A, B> SlicePartialEq<B> for [A]
where
    A: PartialEq<B>,
{
    default fn equal(&self, other: &[B]) -> bool {
        if self.len() != other.len() {
            return false;
        }

        self.iter().zip(other.iter()).all(|(x, y)| x == y)
    }
}

// When each element can be compared byte-wise, we can compare all the bytes
// from the whole size in one call to the intrinsics.
impl<A, B> SlicePartialEq<B> for [A]
where
    A: BytewiseEq<B>,
{
    fn equal(&self, other: &[B]) -> bool {
        if self.len() != other.len() {
            return false;
        }

        // SAFETY: `self` and `other` are references and are thus guaranteed to be valid.
        // The two slices have been checked to have the same size above.
        unsafe {
            let size = mem::size_of_val(self);
            compare_bytes(self.as_ptr() as *const u8, other.as_ptr() as *const u8, size) == 0
        }
    }
}
```

满足`BytewiseEq`特征的话用`compare_bytes`进行比较，否则逐个元素比较。

## `Ord`的特化

```rust
trait SliceOrd: Sized {
    fn compare(left: &[Self], right: &[Self]) -> Ordering;
}

impl<A: Ord> SliceOrd for A {
    default fn compare(left: &[Self], right: &[Self]) -> Ordering {
        let l = cmp::min(left.len(), right.len());

        // Slice to the loop iteration range to enable bound check
        // elimination in the compiler
        let lhs = &left[..l];
        let rhs = &right[..l];

        for i in 0..l {
            match lhs[i].cmp(&rhs[i]) {
                Ordering::Equal => (),
                non_eq => return non_eq,
            }
        }

        left.len().cmp(&right.len())
    }
}

// `compare_bytes` compares a sequence of unsigned bytes lexicographically.
// this matches the order we want for [u8], but no others (not even [i8]).
impl SliceOrd for u8 {
    #[inline]
    fn compare(left: &[Self], right: &[Self]) -> Ordering {
        // Since the length of a slice is always less than or equal to isize::MAX, this never underflows.
        let diff = left.len() as isize - right.len() as isize;
        // This comparison gets optimized away (on x86_64 and ARM) because the subtraction updates flags.
        let len = if left.len() < right.len() { left.len() } else { right.len() };
        // SAFETY: `left` and `right` are references and are thus guaranteed to be valid.
        // We use the minimum of both lengths which guarantees that both regions are
        // valid for reads in that interval.
        let mut order = unsafe { compare_bytes(left.as_ptr(), right.as_ptr(), len) as isize };
        if order == 0 {
            order = diff;
        }
        order.cmp(&0)
    }
}
```



如果类型是`u8`的话，用`compare_bytes`比较。

## SliceContains的特化

contains方法需要用到这个特征

```rust
impl [T] {
    pub fn contains(&self, x: &T) -> bool
    where
        T: PartialEq,
    {
        cmp::SliceContains::slice_contains(x, self)
    }
}
```



```rust
pub(super) trait SliceContains: Sized {
    fn slice_contains(&self, x: &[Self]) -> bool;
}

impl<T> SliceContains for T
where
    T: PartialEq,
{
    default fn slice_contains(&self, x: &[Self]) -> bool {
        x.iter().any(|y| *y == *self)
    }
}

impl SliceContains for u8 {
    #[inline]
    fn slice_contains(&self, x: &[Self]) -> bool {
        memchr::memchr(*self, x).is_some()
    }
}

impl SliceContains for i8 {
    #[inline]
    fn slice_contains(&self, x: &[Self]) -> bool {
        let byte = *self as u8;
        // SAFETY: `i8` and `u8` have the same memory layout, thus casting `x.as_ptr()`
        // as `*const u8` is safe. The `x.as_ptr()` comes from a reference and is thus guaranteed
        // to be valid for reads for the length of the slice `x.len()`, which cannot be larger
        // than `isize::MAX`. The returned slice is never mutated.
        let bytes: &[u8] = unsafe { from_raw_parts(x.as_ptr() as *const u8, x.len()) };
        memchr::memchr(byte, bytes).is_some()
    }
}
```

如果类型是`u8`或者`i8`的话，用`memchr`进行查找。
