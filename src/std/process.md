# process



## Child

子进程的封装

| -      | -           |
| ------ | ----------- |
| stdio  | ChildStdin  |
| stdout | ChildOut    |
| stderr | ChildStderr |


## Command

用来创建子进程，可以指定参数，环境变量，标准输入，标准输出，标准错误

| -      | -     |
| ------ | ----- |
| stdin  | Stdio |
| stdout | Stdio |
| stderr | Stdio |



## FromInner

| FromInner<T>                     |       |
| -------------------------------- | ----- |
| (impl:Process, impl::StdioPipes) | Child |
|                                  |       |

