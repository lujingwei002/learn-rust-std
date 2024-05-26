# Path

## 重点

- 类似str和String，path也分成Path和PathBuf，Path相当于str，是不可变版本，PathBuf相当于String，是可变版本。



## aa

| -       | -        |
| ------- | -------- |
| Path    | OsStr    |
| PathBuf | OsString |



## Prefix

| 类型          | 例子         | prefix_len |
| ------------ | ------------ | ------------ |
| Verbatim     | `\\?\x` | 4 + os_str_len(cat_pics) |
| VerbatimUNC  | `\\?\UNC\x\y` | 8 + os_str_len(x) + if os_str_len(y) > 0 { 1 + os_str_len(y) } else { 0 } |
| VerbatimDisk | `\\?\C:` | 6 |
| DeviceNS     | `\\.\x` | 4 + os_str_len(x) |
| UNC          | `\\x\y` | 2 + os_str_len(x) + if os_str_len(y) > 0 { 1 + os_str_len(y) } else { 0 } |
| Disk         | `C:` | 2 |

