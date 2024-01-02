# process



创建进程时先用Command填充选项，再调用spawn创建进程。

## 设置执行文件和参数

```rust
use std::process::Command;

Command::new("ls")
    .arg("-l")
    .arg("-a")
    .spawn()
    .expect("ls command failed to start");
```

## 设置环境变量

子进程默认继续父进程的环境变量，可以用env，env_clear，env_remove，envs修改，新增或者删除环境变量的值。

```rust
use std::process::Command;

Command::new("ls")
    .env("PATH", "/bin")
    .spawn()
    .expect("ls command failed to start");
```

## 设置管道

stdin，stdout，stderr都可以设置，类型是Stdio。

```rust
use std::process::{Command, Stdio};

Command::new("ls")
    .stdin(Stdio::null())
    .spawn()
    .expect("ls command failed to start");
```

```rust
use std::process::{Command, Stdio};

Command::new("ls")
    .stdout(Stdio::null())
    .spawn()
    .expect("ls command failed to start");
```

只要实现了`Into<Stdio>`特征的都可以作为stdin，stdout，stderr的参数。

```rust
impl Command {
     pub fn stdin<T: Into<Stdio>>(&mut self, cfg: T) -> &mut Command {
        self.inner.stdin(cfg.into().0);
        self
    }
}
```

Stdio提供了几个方法的方法创建管理或者null

```rust
use std::process::{Command, Stdio};

let reverse = Command::new("rev")
    .arg("non_existing_file.txt")
    .stderr(Stdio::piped())
    .spawn()
    .expect("failed reverse command");

let cat = Command::new("cat")
    .arg("-")
    .stdin(reverse.stderr.unwrap()) // Converted into a Stdio here
    .output()
    .expect("failed echo command");

assert_eq!(
    String::from_utf8_lossy(&cat.stdout),
    "rev: cannot open non_existing_file.txt: No such file or directory\n"
);
```

文件也实现了`Into<Stdio>`的特征。

```rust		
use std::fs::File;
use std::process::Command;

// With the `foo.txt` file containing "Hello, world!"
let file = File::open("foo.txt").unwrap();

let reverse = Command::new("rev")
    .stdin(file)  // Implicit File conversion into a Stdio
    .output()
    .expect("failed reverse command");

assert_eq!(reverse.stdout, b"!dlrow ,olleH");
```



## 子进程

子进程是对sys::process，和sys::pipe::AnnoPipe的封装，有三个匿名管理，stdin，stderr，stdout。stdin实现了Write特征，可以住stdin写往子进程传递数据。 stderr和stdout实现了Read特征，可以从stdout里读执行结果

```rust
pub struct Child {
    pub(crate) handle: imp::Process,
    pub stdin: Option<ChildStdin>,
    pub stdout: Option<ChildStdout>,
    pub stderr: Option<ChildStderr>,
}
```



## Termination

main函数返回Termination，实现了Termination特征的都可以作返回值。Termination特征中有一个report方法，返回ExitCode，在linux的实现中是一个u8类型的错误码。

```rust
pub trait Termination {
    fn report(self) -> ExitCode;
}

pub struct ExitCode(u8);
```

当前`()`，`!`，ExitCode，Result<T,E>都 实现了Termination特征。

```rust
impl<T: Termination, E: fmt::Debug> Termination for Result<T, E> {
    fn report(self) -> ExitCode {
        match self {
            Ok(val) => val.report(),
            Err(err) => {
                io::attempt_print_to_stderr(format_args_nl!("Error: {err:?}"));
                ExitCode::FAILURE
            }
        }
    }
}
```

> 其实Result如果是Err的话就返回ExitCode::FAILTURE，即1

