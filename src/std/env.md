# env



## 速览

- Vars是处理环境的。
- Args是处理进程参数的。
- 还有一些获得和操作目录的函数。



## 环境变量

| -          | -                |
| ---------- | ---------------- |
| vars       | 获取全部环境变量 |
| var        | 获取单个环境变量 |
| set_var    | 设置环境变量     |
| remove_var | 删除环境变量     |

## 进程参数

| -    | -                |
| ---- | ---------------- |
| args | 获取全部进程参数 |



## 目录相关

| -           | -                |
| ----------- | ---------------- |
| home_dir    | 获取home目录     |
| temp_dir    | 获取临时目录     |
| current_exe | 进程执行文件名   |
| join_paths  | 合并PATH环境变量 |
| split_paths | 拆分PATH环境变量 |

### split_paths

```rust
use std::env;

let key = "PATH";
match env::var_os(key) {
    Some(paths) => {
        for path in env::split_paths(&paths) {
            println!("'{}'", path.display());
        }
    }
    None => println!("{key} is not defined in the environment.")
}
```

### join_paths

```rust
use std::env;
use std::path::PathBuf;

fn main() -> Result<(), env::JoinPathsError> {
    if let Some(path) = env::var_os("PATH") {
        let mut paths = env::split_paths(&path).collect::<Vec<_>>();
        paths.push(PathBuf::from("/home/xyz/bin"));
        let new_path = env::join_paths(paths)?;
        env::set_var("PATH", &new_path);
    }

    Ok(())
}
```

