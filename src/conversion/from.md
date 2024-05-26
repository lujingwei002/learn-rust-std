# From

## String

| -                     | -                    | -    |
| --------------------- | -------------------- | ---- |
| String                |                      |      |
| String                | `From<&str>`         |      |
| String                | `From<&mut str>`     |      |
| String                | `From<&String>`      |      |
| String                | `From<Box<str>>`     |      |
| `Box<str>`            | `From<String>`       |      |
| String                | `From<Cow<'a, str>>` |      |
| `Cow<'a, str>`        | `From<&'a str>`      |      |
| `Cow<'a, str>`        | From<String>         |      |
| `Cow<'a, str>`        | `From<&'a String>`   |      |


## Arc

| -                     | -                    | -    |
| --------------------- | -------------------- | ---- |
| `Arc<T>`              | `From<T>`            |      |
| `Arc<[T]>`            | `From<[T;N]>`        |      |
| `Arc<[T]>`            | `From<&[T]>`         |      |
| `Arc<str>`            | `From<&str>`         |      |
| `Arc<str>`            | `From<String>`       |      |
| `Arc<T,A>`            | `From<Box<T,A>>`     |      |
| `Arc<[T], A>`         | `From<Vec<T, A>>`    |      |
| `Arc<B>`              | `From<Cow<'a, B>>`   |      |
| `Arc<[u8]>`           | `From<Arc<str>>`     |      |

## Box
| -                     | -                    | -    |
| --------------------- | -------------------- | ---- |
| `Box<T>`              | `From<T>`            |      |
| `Pin<Box<T, A>>`      | `From<Box<T, A>>`    |      |
| `Box<[T]>`            | `From<&[T]>`         |      |
| `Box<[T]>`            | `From<Cow<'_, [T]>>` |      |
| `Box<str>`            | `From<&str>`         |      |
| `Box<str>`            | `From<Cow<'_, str>>` |      |
| `Box<[u8], A>`        | `From<Box<str, A>>`  |      |
| `Box<[T]>`            | `From<[T; N]>`       |      |
| `Box<dyn Error + 'a>` | `From<E>`            |      |

## Rc

| -            | -                  | -        |
| ------------ | ------------------ | -------- |
| `Rc<T>`      | `From<T>`          |          |
| `Rc<T>`      | `From<[T; N]>`     |          |
| `Rc<[T]>`    | `From<&[T]>`       | T: Clone |
| `Rc<str>`    | `From<&str>`       |          |
| `Rc<str>`    | `From<String>`     |          |
| `Rc<T, A>`   | `From<Box<T, A>>`  |          |
| `Rc<[T], A>` | `From<Vec<T, A>>`  |          |
| `Rc<B>`      | `From<Cow<'a, B>>` |          |
| `Rc<[u8]>`   | `From<Rc<str>>`    |          |
| `Rc<[T; N]>` | `TryFrom<Rc<[T]>>` |          |
| `Rc<[T]>`    | `FromIterator<T>`  |          |

