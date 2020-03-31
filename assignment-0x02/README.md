# Linux 命令行使用基础

## 实验要求

vimtutor 操作全程录像

## 实验环境

### AC-Server

- 镜像：`ubuntu-18.04.4-server-amd64.iso`
- 网卡：NAT 网络 + Host-Only

### asciinema

```bash
# install
sudo apt install asciinema

# Link install ID with asciinema.org user account
asciinema auth
```

## 操作录像

### Vimtutor - Lesson 1

<a href="https://asciinema.org/a/k04nNLTKZIn1OJPvovIy8AVlr" target="_blank"><img src="https://asciinema.org/a/k04nNLTKZIn1OJPvovIy8AVlr.svg" width=550px/></a>

### Vimtutor - Lesson 2

<a href="https://asciinema.org/a/iLTl9Y48AgBKUZO3X84naKsPM" target="_blank"><img src="https://asciinema.org/a/iLTl9Y48AgBKUZO3X84naKsPM.svg" width=550px/></a>

### Vimtutor - Lesson 3

<a href="https://asciinema.org/a/AShdqFi03OmSZjIQlYQJlkzmb" target="_blank"><img src="https://asciinema.org/a/AShdqFi03OmSZjIQlYQJlkzmb.svg" width=550px/></a>

### Vimtutor - Lesson 4

<a href="https://asciinema.org/a/PHwLIgvcQ8xkRkWgUsgOXM0jr" target="_blank"><img src="https://asciinema.org/a/PHwLIgvcQ8xkRkWgUsgOXM0jr.svg" width=550px/></a>

### Vimtutor - Lesson 5

<a href="https://asciinema.org/a/ieRw9PSvEZWLshaUJPiuFOb2S" target="_blank"><img src="https://asciinema.org/a/ieRw9PSvEZWLshaUJPiuFOb2S.svg" width=550px/></a>

### Vimtutor - Lesson 6

<a href="https://asciinema.org/a/XCs00td9xHvSMuKnGh0ZsXw1S" target="_blank"><img src="https://asciinema.org/a/XCs00td9xHvSMuKnGh0ZsXw1S.svg" width=550px/></a>

### Vimtutor - Lesson 7

<a href="https://asciinema.org/a/IMgN2u3L4opFhRvGiTwFE63Ac" target="_blank"><img src="https://asciinema.org/a/IMgN2u3L4opFhRvGiTwFE63Ac.svg" width=550px/></a>

## 自查清单

### Vim 有哪几种工作模式？

Normal 模式、Insert 模式、Visual 模式、Replace 模式、Command-line 模式、Select 模式、Ex 模式

### Normal 模式下，从当前行开始，一次向下移动光标 10 行的操作方法？如何快速移动到文件开始行和结束行？如何快速跳转到文件中的第 N 行？

- 一次向下移动光标 10 行：`10j`
- 快速移动到文件开始行：`gg`
- 快速移动到文件结束行：`G`
- 快速跳转到文件中的第 N 行：`NG`/`Ngg`

### Normal 模式下，如何删除单个字符、单个单词、从当前光标位置一直删除到行尾、单行、当前行开始向下数 N 行？

- 删除单个字符：光标移动到要删除的字符，键入`x`
- 删除单个单词：`dw`或`de`（两者有所不同）
  ```bash
  There are a cats.

  # 使用 dw 删除
  There are cats.

  # 使用 de 删除，cats 前的空格没有删除
  There are  cats.
  ```
- 从当前光标位置一直删除到行尾：`d$`
- 删除单行：`dd`
- 删除当前行开始向下数 N 行：`Ndd`

### 如何在 vim 中快速插入 N 个空行？如何在 vim 中快速输入 80 个 - ？

- 快速插入 N 个空行：`NO`+`Esc`（在光标上方插入）/`No`+`Esc`（在光标下方插入）
- 快速输入 80 个 -：Normal 模式下，`80i-`/`80a-`/`80A-`+`ESC`

### 如何撤销最近一次编辑操作？如何重做最近一次被撤销的操作？

- 撤销最近一次编辑操作：`u`
- 重做最近一次被撤销的操作：`CTRL-R`

### vim 中如何实现剪切粘贴单个字符？单个单词？单行？如何实现相似的复制粘贴操作呢？

- 剪切
  - 单个字符：`x`/`dl`
  - 单个单词：`dw`
  - 单行：`dd`
- 复制
  - 单个字符：`yl`
  - 单个单词：`yw`
  - 单行：`yy`
- 粘贴：`p`（在光标之后）/`P`（在光标之前）

### 为了编辑一段文本你能想到哪几种操作方式（按键序列）？

- 插入：`i/a/A`
- 修改：`r`、`R`、`c`、`:s/old/new`
- 删除：`x`、`d`
- 粘贴：`p/P`

### 查看当前正在编辑的文件名的方法？查看当前光标所在行的行号的方法？

使用`CTRL-G`可以查看当前正在编辑的文件名和当前光标所在行的行号。

### 在文件中进行关键词搜索你会哪些方法？如何设置忽略大小写的情况下进行匹配搜索？如何将匹配的搜索结果进行高亮显示？如何对匹配到的关键词进行批量替换？

- 进行关键词搜索：`/pattern`
- 设置忽略大小写：`:set ic`
  - 单次搜索忽略大小写使用：`/pattern\c`
- 将匹配的搜索结果进行高亮显示：`:set hls`
- 将`a`批量替换为`b`：`:%s/a/b/g`

### 在文件中最近编辑过的位置来回快速跳转的方法？

在 Normal 模式下使用`CTRL-O`（向后）和`CTRL-I`（向前）。

### 如何把光标定位到各种括号的匹配项？例如：找到(, [, or {对应匹配的),], or }

光标先移动到一对括号的其中一个，按下`%`后，光标会移动到其对应匹配的括号。

### 在不退出 vim 的情况下执行一个外部程序的方法？

Normal 模式下，输入`:!`，其后跟随需要执行的外部程序的指令。

### 如何使用 vim 的内置帮助系统来查询一个内置默认快捷键的使用方法？如何在两个不同的分屏窗口中移动光标？

- 使用 vim 的内置帮助系统查询一个内置默认快捷键的使用方法（如`w`）：在 Normal 模式下，输入`:help w`
- 有些快捷键在不同工作模式下作用不同
  - `:help <Shortcut>` 查询 Normal 模式下的快捷键
  - `:help i_<Shortcut>` 查询 Insert 模式下的快捷键
  - `:help c_<Shortcut>` 查询 Command-line 模式下的快捷键
  - `:help v_<Shortcut>` 查询 Visual 模式下的快捷键
- 在两个不同的分屏窗口中移动光标：`CTRL-W CTRL-W`

## 参考资料

- [Asciinema - Getting started](https://asciinema.org/docs/getting-started)
- [Vim documentation: intro](http://vimdoc.sourceforge.net/htmldoc/intro.html#vim-modes-intro)
- [Repeating characters in VIM insert mode](https://stackoverflow.com/questions/5054128/repeating-characters-in-vim-insert-mode)