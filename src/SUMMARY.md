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
- [智能指针](./ptr/smart_ptr.md)
  - [Rc](./ptr/rc.md)
  - [Arc](./ptr/arc.md)

# 特征篇

---
- [trait](./trait/intro.md)
  - [cmp](./trait/cmp.md)
  - [borrow](./trait/borrow.md)
  - [unsize](./trait/unsize.md)
  - [deref](./trait/deref.md)
  - [index](./trait/index.md)
  - [range](./trait/range.md)




# 类型篇
---
- [类型](./type/intro.md)
  - [size](./type/size.md)
  - [unsize](./type/unsize.md)
- [类型转换](./conversion/intro.md)
  - [unsize](./conversion/coercion.md)
- [字符串](./string/intro.md)
  - [编码](./string/code.md)
  - [ascii](./string/ascii.md)
  - [char](./string/char.md)
  - [str](./string/str.md)
- [切片](./slice/intro.md)
  - [slice](./slice/slice.md)
  - [cmp](./slice/cmp.md)
- [unit](./unit/intro.md)
- [元组](./tuple/intro.md)

# 错误处理
- [result](./result/result.md)
- [error](./error/intro.md)
  - [result](./result/result.md)
  - [error](./error/error.md)
  - [panic](./panic/panic.md)
  - [unwind](./panic/unwind.md)

# 标准库
- [std](./std/std.md)
  - [env](./std/env.md)
  - [path](./std/path.md)
  - [process](./std/process.md)

# future

---
- [future](./future/intro.md)
  - [future](./future/future.md)
  - [waker](./future/waker.md)
  - [futures-task](./future/futures-task.md)
  - [futures-executor](./future/futures-executor.md)

# 实例

---
- [error](./examples/error/intro.md)
  - [kind](./examples/error/kind.md)	
- [iter](./examples/iter/intro.md)
  - [iter::try_process](./examples/iter/try_process.md)