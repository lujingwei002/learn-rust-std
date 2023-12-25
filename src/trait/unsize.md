# unsize



## Unsize

### 这个特征有什么用？



## CoerceUnsized

### 这个特征有什么用？

配合`Unsize`来做类型转换，例如将`&[T; N]`转型为`&[T]`，因为`[T; N]`实现了`Unsize<[T]>`

### 转换built in pointer type

- `T: ?Size + Unsize<U>`
- `U: ?Size`

| -        | -        |
| -------- | -------- |
| &mut T   | &mut U   |
| &mut T   | &U       |
| &mut T   | *mut U   |
| &mut T   | *const U |
| &T       | &U       |
| &T       | *const U |
| *mut T   | *mut U   |
| *mut T   | *const U |
| *const T | *const U |

### 转换smart pointer

- `T: ?Size + Unsize<U>`
- `U: ?Size`

| -            | -            |
| ------------ | ------------ |
| `Arc<T>`     | `Arc<U>`     |
| `Box<T>`     | `Box<U>`     |
| `NonNull<T>` | `NonNull<U>` |
| `Unique<T>`  | `Unique<U>`  |
| `Rc<T>`      | `Rc<U>`      |
| `RefMut<T>`  | `RefMut<U>`  |
| `Ref<T>`     | `Ref<U>`     |
| `Weak<T>`    | `Weak<U>`    |

例如，将`Rc<T>`转换为`Rc<U>`。

```rust
let r = Rc::new([1,2,3]);
let r3 = r as Rc<[i32]>;
```

但不能将`&Rc<T>`转型为`&Rc<U>`

```rust
let r = Rc::new([1,2,3]);
let r2 = &r;
let r3 = r2 as &Rc<[i32]>;
```



### 转换cell类型

`T: CoerceUnsized<U>`

| -                   | -                   |
| ------------------- | ------------------- |
| `Cell<T>`           | `Cell<U>`           |
| `Pin<T>`            | `Pin<U>`            |
| `RefCell<T>`        | `RefCell<U>`        |
| `UnsafeCell<T>`     | `UnsafeCell<U>`     |
| `SyncUnsafeCell<T>` | `SyncUnsafeCell<U>` |

例如，`RefCell<Box<T>>`转型为`RefCell<Box<U>>`

```rust
let r = RefCell::new(Box::new([1,2,3]));
let r2 = r as RefCell<Box<[i32]>>;
```

## DispatchFromDyn



### 这个特征有什么用？

和`CoerceUnsize`相反，是从fat pointer转型为`thin pointer`，或者叫`CoerceSized`更合适。但只用于method receiver。

不要和`Receiver`特征搞混，`Receiver`是约束哪些类型可以作为method receiver，而`DispatchFromDyn`是表示可以转型。

### 转换built in pointer type

- `T: ?Size + Unsize<U>`
- `U: ?Size`

| -        | -        |
| -------- | -------- |
| &mut T   | &mut U   |
| &T       | &U       |
| *mut T   | *mut U   |
| *const T | *const U |

例如 从`&Line`转型为`&dyn Draw`

```rust
trait Draw {
    fn draw(&self);
}

struct Line {

}
impl Draw for Line {
    fn draw(&self) {
        println!("ccc");
    }
}
```



### 转换smart pointer

- `T: ?Size + Unsize<U>`
- `U: ?Size`

| -            | -            |
| ------------ | ------------ |
| `Arc<T>`     | `Arc<U>`     |
| `Box<T>`     | `Box<U>`     |
| `NonNull<T>` | `NonNull<U>` |
| `Unique<T>`  | `Unique<U>`  |
| `Rc<T>`      | `Rc<U>`      |
| `Weak<T>`    | `Weak<U>`    |

例如 从`Box<Line>`转型为`Box<dyn Draw>`

```rust
trait Draw {
    fn draw(self:Box<Self>);
}

struct Line {

}
impl Draw for Line {
    fn draw(self:Box<Self>) {
        println!("ccc");
    }
}
```

但不能从`&Box<Line>`转型为`&Box<dyn Draw>`

```rust
trait Draw {
    fn draw(self:&Box<Self>);
}

struct Line {

}
impl Draw for Line {
    fn draw(self:&Box<Self>) {
        println!("ccc");
    }
}
```



### 转换cell类型

`T: CoerceUnsized<U>`

| -                   | -                   |
| ------------------- | ------------------- |
| `Cell<T>`           | `Cell<U>`           |
| `Pin<T>`            | `Pin<U>`            |
| `UnsafeCell<T>`     | `UnsafeCell<U>`     |
| `SyncUnsafeCell<T>` | `SyncUnsafeCell<U>` |

