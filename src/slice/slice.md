# slice



## 接口



### from_raw

| 函数               | 说明                     |
| ------------------ | ------------------------ |
| from_raw_parts     | 从ptr和len创建           |
| from_raw_parts_mut | 从ptr和len创建           |
| from_ref           | 从引用创建单个元素的切片 |
| from_mut           | 从引用创建单个元素的切片 |
| from_ptr_range     | 从起始指针和结束指针创建 |
| from_mut_ptr_range | 从起始指针和结束指针创建 |
|                    |                          |

### 查找

| -                | -    |
| ---------------- | ---- |
| contains         |      |
| starts_with      |      |
| ends_with        |      |
| binary_search    |      |
| binary_search_by |      |
|                  |      |

### 排序

| -                      | -    |
| ---------------------- | ---- |
| sort_unstable_by       |      |
| select_nth_unstable_by |      |
|                        |      |



### 前1个元素

| 左侧开始    | 右侧开始   | 返回值             |
| ----------- | ---------- | ------------------ |
| first       | last       | Option<&T>         |
| split_first | split_last | Option<(&T, &[T])> |
| take_first  | take_last  | Option<&'a T>      |
|             |            |                    |



### 前N个元素

| 左侧开始          | 右侧开始         | 返回值                  | 返回值                  |
| ----------------- | ---------------- | ----------------------- | ----------------------- |
| first_chunk       | last_chunk       | Option<&[T; N]>         |                         |
| split_first_chunk | split_last_chunk | Option<(&[T; N], &[T])> | Option<(&[T; N], &[T])> |
| split_array_ref   | rsplit_array_ref | (&[T; N], &[T])         | (&[T], &[T; N])         |



### split

| 左侧开始        | 右侧开始    | 返回值         | 返回值  |
| --------------- | ----------- | -------------- | ------- |
| split_once      | rsplit_once |                |         |
| split_at        |             | (&[T], &[T])   |         |
| split           | rsplit      | Split          | RSplit  |
| split_inclusive |             | SplitInclusive |         |
| splitn          | rsplitn     | SplitN         | RSplitN |



### chunks

| 左侧开始            | 右侧开始      | 返回值            | 返回值            |
| ------------------- | ------------- | ----------------- | ----------------- |
| as_chunks           | as_rchunks    | (&[[T; N]], &[T]) | (&[T], &[[T; N]]) |
| as_chunks_unchecked |               | &[[T; N]]         |                   |
| chunks              | rchunks       | Chunks            | RChunks           |
| chunks_exact        | rchunks_exact | ChunksExact       | RChunksExact      |
| array_chunks        |               |                   | ArrayChunks       |



### 范围

| -            |      | -    |                                         |
| ------------ | ---- | ---- | --------------------------------------- |
| take         |      |      |                                         |
| get_many_mut |      | 1    | Result<[&mut T; N], GetManyMutError<N>> |



