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
  - [UniqueRc](./ptr/unique_rc.md)
  - [Arc](./sync/arc.md)

# 类型篇
---
- [构造函数](./type/constructor.md)
- [值类型](./type/value.md)
  - [UnsafeCell](./type/value/UnsafeCell.md)
  - [SyncUnsafeCell](./type/value/SyncUnsafeCell.md)
  - [Cell](./type/value/cell.md)
- [指针类型](./type/ptr.md)
  - [Ref](./type/ptr/Ref.md)
  - [RefMut](./type/ptr/RefMut.md)
- [unit](./unit/intro.md)
- [切片](./slice/intro.md)
  - [slice](./slice/slice.md)
  - [cmp](./slice/cmp.md)
  - [Vec](./vec/vec.md)
- [元组](./tuple/intro.md)
- [字符串](./string/intro.md)
  - [编码](./string/code.md)
  - [ascii](./string/ascii.md)
  - [char](./string/char.md)
  - [str](./string/str.md)
  - [CStr](./string/CStr.md)
  - [CString](./string/CString.md)
  - [String](./string/String.md)
  
# 变型篇

---
- [类型转换](./conversion/intro.md)
- [借用](./conversion/trait/trait.md)
  - [borrow](./conversion/trait/borrow.md)
  - [ToOwned](./conversion/trait/to_owned.md)
- [convert](./convert/intro.md)
  - [unsize](./conversion/coercion.md)
  - [实现](./convert/impl.md)
  - [size](./type/size.md)
  - [unsize](./type/unsize.md)
  - [From](./conversion/from.md)
  - [FromIterator](./conversion/from_iterator.md)



# 特征篇


---
- [trait](./trait/intro.md)
  - [cmp](./trait/cmp.md)
  - [borrow](./trait/borrow.md)
  - [unsize](./trait/unsize.md)
  - [deref](./trait/deref.md)
  - [index](./trait/index.md)
  - [range](./trait/range.md)



# 错误处理
- [result](./result/result.md)
- [error](./error/intro.md)
  - [error](./error/error.md)
- [panic](./panic/panic.md)
  - [backtrace](./backtrace/backtrace.md)
  - [unwind](./panic/unwind.md)

# 标准库
- [std](./std/std.md)
  - [env](./std/env.md)
  - [rt](./std/rt.md)
  
# io
- [文件系统](./std/file.md)
	- [path](./std/path.md)
	- [文件操作](./std/fs.md)
- [io](./io/intro.md)
  - [特征](./io/trait.md)
  - [错误处理](./io/error.md)


# 多线程
- [进程](./std/process.md)
- [线程](./thread/thread.md)
  - [local key](./thread/local_key.md)
- [sync](./sync/sync.md)
  - [poison](./sync/poison.md)
  - [futex](./sync/futex.md)
  - [mutex](./sync/mutex.md)	
  - [remutex](./sync/remutex.md)	
  - [rwlock](./sync/rwlock.md)	
  - [condvar](./sync/condvar.md)	
  - [barrier](./sync/barrier.md)

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
