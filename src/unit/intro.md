# unit

## 将`()`iter转为()



```rust
use std::io::*;
let data = vec![1, 2, 3, 4, 5];
let res: Result<()> = data.iter()
     .map(|x| writeln!(stdout(), "{x}"))
     .collect();
assert!(res.is_ok());
```

> collect方法需要 () 实现 FromIterator<()>特征

```rust
impl FromIterator<()> for () {
    fn from_iter<I: IntoIterator<Item = ()>>(iter: I) -> Self {
        iter.into_iter().for_each(|()| {})
    }
}
```