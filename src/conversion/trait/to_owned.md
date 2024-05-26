# ToOwned

和Borrow特征相反，将`&T`转为`T`。对于实现了Clone特征的类型，ToOwned就是调用clone方法，克隆出值。

```rust
pub trait ToOwned {
    type Owned: Borrow<Self>;

    fn to_owned(&self) -> Self::Owned;

    fn clone_into(&self, target: &mut Self::Owned) {
        *target = self.to_owned();
    }
}

impl<T> ToOwned for T
where T: Clone,
{
    type Owned = T;
    fn to_owned(&self) -> T {
        self.clone()
    }

    fn clone_into(&self, target: &mut T) {
        target.clone_from(self);
    }
}
```

当前在标准库中实现了ToOwned的类型有

| -      | where    | Owned        |
| ------ | -------- | -------- |
| &T     | T: Clone | T        |
| &[T]   |          | Vec<T>   |
| &str   |          | String   |
| &OsStr |          | OsString |
| &CStr  |          | CString  |
| &Path  |          | PathBuf  |

