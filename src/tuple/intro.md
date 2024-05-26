# tuple

## 为12个元素以内的tuple实现特征

- PartialEq
- Eq
- ConstParamTy
- StructuralEq
- PartialOrd
- Ord
- Default
- Form



## 12个元素以内的tubple与数组的转换

```rust
let arr: [i32;3] = (1,2,3).into();

let t :(i32, i32, i32) = [1,2,3].into();
```

