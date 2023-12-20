# slice



## 接口

### 查找

- contains(&self, x: &T) -> bool
- starts_with(&self, needle: &[T]) -> bool
- ends_with(&self,  needle: &[T])- > bool
- binary_search(&self, x: &T) -> Result<usize, usize>
- binary_search_by(&self, mut f: T) -> Result<usize, usize>

### 排序

- sort_unstable_by
- select_nth_unstable_by
