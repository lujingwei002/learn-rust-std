# install

## 怎么安装rust library的源代码
```bash
# 下载nightly toolchain
rustup toolchain install nightly-mvsc
# 下载源码组件
rustup component add rust-src
```
安装后的路径在  
`$HOME\.rustup\toolchains\nightly-x86_64-pc-windows-msvc\lib\rustlib\src\rust\library`
> 其中`nightly-x86_64-pc-windows-msvc`为当前所用的toolchain


## 怎么安装rust std的源代码
```bash
rustup component add rust-src
```