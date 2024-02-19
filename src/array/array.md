# array



## 构造函数

| -                  | -                   | -                                     |
| ------------------ | ------------------- | ------------------------------------- |
| from_fn            | `FnMut(size) -> T`  | `[T; N]`                              |
| try_from_fn        | `FnMut(usize) -> R` | `ChangeOutputType<R, [R::Output; N]>` |
| try_from_fn_erased | `FnMut(usize) -> R` | `ControlFlow<R::Residual>`            |
| from_ref           | `&T`                | `&[T; 1]`                             |
| from_mut           | `&mut T`            | `&mut [T; 1]`                         |



# 转型

| -                | -             | -                         |
| ---------------- | ------------- | ------------------------- |
| as_slice         | `& [T; N]`    | `&[T]`                    |
| as_mut_slice     | `&mut [T; N]` | `&mut [T]`                |
| each_ref         | `&[T; N]`     | `[&T; N]`                 |
| each_mut         | `&mut [T; N]` | `[&mut T; N]`             |
| split_array_ref  | `& [T; N]`    | `(&[T; M], &[T])`         |
| split_array_mut  | `&mut [T; N]` | `(&mut [T; M], &mut [T])` |
| rsplit_array_ref | `&[T; N]`     | `(&[T], &[T; M])`         |
| rsplit_array_mut | `&mut [T; N]` | `(&mut [T], &mut [T; M])` |





## Drain

迭代数组，保证drop掉没剩下没迭代完的元素。

```rust
pub(crate) fn drain_array_with<T, R, const N: usize>(
    array: [T; N],
    func: impl for<'a> FnOnce(Drain<'a, T>) -> R,
) -> R {
    let mut array = ManuallyDrop::new(array);
    let drain = Drain(array.iter_mut());
    func(drain)
}
```

> `let mut array = ManuallyDrop::new(array)`，数组的释放交给Drain来控制。

```rust
pub(crate) struct Drain<'a, T>(slice::IterMut<'a, T>);

impl<T> Drop for Drain<'_, T> {
    fn drop(&mut self) {
        unsafe { drop_in_place(self.0.as_mut_slice()) }
    }
}
```

> drop掉剩下没迭代完的元素。

目前只在array的try_map方法里用到

```rust
pub fn try_map<F, R>(self, f: F) -> ChangeOutputType<R, [R::Output; N]>
where
    F: FnMut(T) -> R,
    R: Try,
    R::Residual: Residual<[R::Output; N]>,
{
    drain_array_with(self, |iter| try_from_trusted_iterator(iter.map(f)))
}
```

## PartialEq

| -                     | -        | -               |
| --------------------- | -------- | --------------- |
| `[B]`                 | `[A]`    |                 |
| `[B; N]`              | `[A: N]` | A: PartialEq<B> |
| `[B]` 转为 `[B; N]`   | `[A; N]` |                 |
| `&[B]` 转为 `[B]`     | `[A; N]` |                 |
| `&mut [B]` 转为 `[B]` | `[A; N]` |                 |

