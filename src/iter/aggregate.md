# 聚合操作



## sum

将全部元素累加起来。例子：

```rust
fn main() {
    let v = vec![1, 2, 3];
    let res:i32 = v.iter().sum();
    // 1 + 2 + 3
     assert_eq!(6, res);
}
```

元素需要实现`Sum`特征

```rust
pub trait Sum<A = Self>: Sized {
    /// Method which takes an iterator and generates `Self` from the elements by
    /// "summing up" the items.
    #[stable(feature = "iter_arith_traits", since = "1.12.0")]
    fn sum<I: Iterator<Item = A>>(iter: I) -> Self;
}
```

比如

```rust
impl Sum for i8 {
    fn sum<I: Iterator<Item=Self>>(iter: I) -> Self {
        iter.fold(
            0,
            |a, b| a + b,
        )
    }
}
```

如果元素类型是`Option`或者`Result`，如果值是`None`或者`Err`的话，累计会中上，并返回`None`或者`Err`。

```rust
fn main() {
    let f = |&x: &i32| if x < 0 { Err("Negative element found") } else { Ok(x) };
    let v = vec![1, 2];
    let res: Result<i32, _> = v.iter().map(f).sum();
    assert_eq!(res, Ok(3));
    let v = vec![1, -2];
    let res: Result<i32, _> = v.iter().map(f).sum();
    assert_eq!(res, Err("Negative element found"));
}
```



## product

将全部元素累乘起来。例子：

```rust
fn main() {
    let v = vec![1, 2, 3];
    let res:i32 = v.iter().product();
    // 1 x 2 x 3
     assert_eq!(6, res);
}
```

元素需要实现`Product`特征

```rust
pub trait Product<A = Self>: Sized {
    /// Method which takes an iterator and generates `Self` from the elements by
    /// multiplying the items.
    #[stable(feature = "iter_arith_traits", since = "1.12.0")]
    fn product<I: Iterator<Item = A>>(iter: I) -> Self;
}
```

比如

```rust
impl Product for i8 {
    fn product<I: Iterator<Item=Self>>(iter: I) -> Self {
        iter.fold(
            1,
            #[rustc_inherit_overflow_checks]
                |a, b| a * b,
        )
    }
}
```

如果元素类型是`Option`或者`Result`，如果值是`None`或者`Err`的话，累计会中上，并返回`None`或者`Err`。

```rust
fn main() {
    let nums = vec!["5", "10", "1", "2"];
    let total: Option<usize> = nums.iter().map(|w| w.parse::<usize>().ok()).product();
    assert_eq!(total, Some(100));
    let nums = vec!["5", "10", "one", "2"];
    let total: Option<usize> = nums.iter().map(|w| w.parse::<usize>().ok()).product();
    assert_eq!(total, None);
}
```

