# result

## 接口

- T => U
- E => F
- f使用于t
- else使用于e

## if分支

| 接口              | Ok        | Err          |              |
| ----------------- | --------- | ------------ | ------------ |
| map               | Ok(f(t))  | Err(e)       | Result<U, E> |
| map_or            | f(t)      | U::default() | U            |
| map_or_else       | f(t)      | else(e)      | U            |
| unwrap            | t         | panic        | T            |
| unwrap_or_default | t         | T::default() | T            |
| unwrap_or         | t         | default      | T            |
| unwrap_or_else    | t         | else(e)      | T            |
| unwrap_unchecked  | t         | panic        | T            |
| ok                | Option<T> | None         | Option<T>    |
| expect            | t         | panic        | T            |
| and               | res       | Err(e)       | Result<U, E> |
| and_then          | f(t)      | Err(e)       | Result<U, E> |
| is_ok             | true      | false        | bool         |
| is_ok_and         | f(t)      | false        | bool         |
| ok                | Some(t)   | None         | Option<T>    |
| inspect           | f(t)      |              | Self         |

## else分支

| 接口                 | Ok    | Err       |              |
| -------------------- | ----- | --------- | ------------ |
| map_err              | Ok(t) | Err(f(e)) | Result<T, F> |
| unwrap_err           | panic | e         | E            |
| unwrap_err_unchecked | panic | e         | E            |
| err                  | None  | Some(e)   | Option<E>    |
| expect_err           | panic | e         | E            |
| or                   | Ok(t) | res       | Result<T, F> |
| or_else              | Ok(t) | else(e)   | Result<T, F> |
| is_err               | false | true      | bool         |
| is_err_and           | false | else(e)   | bool         |
| err                  | None  | Some(e)   | Option<E>    |
| inspect_err          |       | else(e)   | Self         |

