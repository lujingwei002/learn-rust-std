# Cell

使用Cell，使得我们在拥有不可变引用的情况下，也能修改其值。基本用法如下：

```rust
use std::cell::*;

fn main() {
    let c = Cell::new(1);
    c.set(2);
    println!("{}", c.get());
}
```

