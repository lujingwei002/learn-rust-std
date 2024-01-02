# From



| -             | -                  | -    |
| ------------- | ------------------ | ---- |
| `Arc<T>`      | `From<T>`          |      |
| `Arc<[T]>`    | `From<[T;N]>`      |      |
| `Arc<[T]>`    | `From<&[T]>`       |      |
| `Arc<str>`    | `From<&str>`       |      |
| `Arc<str>`    | `From<String>`     |      |
| `Arc<T,A>`    | `From<Box<T,A>>`   |      |
| `Arc<[T], A>` | `From<Vec<T, A>>`  |      |
| `Arc<B>`      | `From<Cow<'a, B>>` |      |
| `Arc<[u8]>`   | `From<Arc<str>>`   |      |

