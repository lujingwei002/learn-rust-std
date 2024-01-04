# borrow

## 重点

- A type is free to borrow as several different types.

- In particular `Eq`, `Ord` and `Hash` must be equivalent for borrowed and owned values: `x.borrow() == y.borrow()` should give the same result as `x == y`.

  - 比如`HashMap`就需要 `Borrow<Q>`和Q产生相同的`Hash`值

    ```rust
    use std::borrow::Borrow;
    use std::hash::Hash;
    
    pub struct HashMap<K, V> {
        // fields omitted
    }
    
    impl<K, V> HashMap<K, V> {
        pub fn insert(&self, key: K, value: V) -> Option<V>
        where K: Hash + Eq
        {
            // ...
        }
    
        pub fn get<Q>(&self, k: &Q) -> Option<&V>
        where
            K: Borrow<Q>,
            Q: Hash + Eq + ?Sized
        {
            // ...
        }
    }
    ```

    

- If generic code merely needs to work for all types that can provide a reference to related type `T`, it is often better to use `AsRef`as more types can safely implement it.

## Borrow

| -         | -        | -    |
| --------- | -------- | ---- |
| T         | &T       | 值借用出不可变引用     |
| &T        | &T       |  不可变引用借用出不可变引用    |
| &mut T    | &T       | 可变引用借用出不可变引用     |
| [T; N] | &[T] | 数组借用出切片 |
| `Vec<T, A>` | &[T]     |   Vec借用出切片   |
| PathBuf   | &Path    |      |
| CString | &CStr |      |
| OsString  | &OsStr   |      |
| String    | &str     |      |
| `Cow<'a, B>` | &B       |      |
| `Box<T, A>` | &T       |      |
| `Rc<T, A>`  | &T       |      |
| `Arc<T, A>` | &T       |      |

## BorrowMut

| -         | -        |
| --------- | -------- |
| T         | &mut T   |
| &mut T    | &mut T   |
| [T; N]    | &mut [T] |
| String    | &mut str |
| `Vec<T, A>` | &mut [T] |
| `Box<T, A>` | &mut T   |

