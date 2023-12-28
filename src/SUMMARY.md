# Learn From Rust Std

[关于本书](./about_book.md)
[install](./install.md)

# 内存篇
---
- [内存布局](./chapter_1.md)
    - [对齐](./layout/alignment.md)
    - [布局](./layout/layout.md)
    - [repr](./layout/repr.md)
- [指针](./chapter_1.md)
- [申请内存](./allocator/intro.md)
    - [global_alloc](./allocator/global_alloc.md)
    - [allocator](./allocator/allocator.md)
    - [rawvec](./allocator/rawvec.md)
    - [box](./allocator/box.md)
- [mem](./chapter_1.md)

# 类型篇
---
- [类型](./type/intro.md)
  - [size](./type/size.md)
  - [unsize](./type/unsize.md)
- [类型转换](./conversion/intro.md)
  - [unsize](./conversion/coercion.md)
- [convert](./convert/intro.md)
  - [实现](./convert/impl.md)
# 基础
---
- [trait](./trait/intro.md)
  - [cmp](./trait/cmp.md)
  - [borrow](./trait/borrow.md)
- [slice](./slice/intro.md)
  - [slice](./slice/slice.md)
  - [cmp](./slice/cmp.md)

- [unit](./unit/intro.md)
- [tuple](./tuple/intro.md)
- [result](./result/intro.md)

# future
---
- [future](./future/intro.md)
  - [futures-task](./future/futures-task.md)
  - [futures-executor](./future/futures-executor.md)

# 实例

---
- [error](./examples/error/intro.md)
  - [kind](./examples/error/kind.md)	
- [iter](./examples/iter/intro.md)
  - [iter::try_process](./examples/iter/try_process.md)