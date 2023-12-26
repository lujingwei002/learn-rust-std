# Path

## 重点

- 类似str和String，path也分成Path和PathBuf，Path相当于str，是不可变版本，PathBuf相当于String，是可变版本。



## aa

| -       | -        |
| ------- | -------- |
| Path    | OsStr    |
| PathBuf | OsString |



## Prefix

| 类型          | 例子         |
| ------------ | ------------ |
| Verbatim     | `\\?\cat_pics` |
| VerbatimUNC  | `\\?\UNC\server\share` |
| VerbatimDisk | `\\?\C:` |
| DeviceNS     | `\\.\COM42` |
| UNC          | `\\server\share` |
| Disk         | `C:` |

