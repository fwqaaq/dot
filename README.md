<div align=center>
   <h1>NVIM 配置⚙️</h1>
  <img style="margin: 0 auto;" src="https://github.com/fwqaaq/dot/assets/82551626/1964f701-bc7b-40b7-b2b1-3ff0bccd2400" />
</div>

> 本仓库的部分配置参考自 [Youtube Josean Martinez](https://www.youtube.com/watch?v=vdn_pKJUda8&t=3228s)

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/fwqaaq/dot/main/install.sh)"
```

## 使用

> 快捷键，leader 键为 \<space>

| 快捷键      | 等同于         | 作用                     |
| ----------- | -------------- | ------------------------ |
| jk          | \<esc>         | 退出编辑模式（i 模式下） |
| \<leader>nh | :nohl\<CR>     | 代替 `:` 在终端中的搜索  |
| x           | "\_x           | 删除光标下的字符         |
| \<leader>+  | \<C-a>         | 自增                     |
| \<leader>-  | \<C-x>         | 自减                     |
| \<leader>sv | \<C-w>v        | 垂直方向分割窗口         |
| \<leader>sh | \<C-w>s        | 水平方向分割窗口         |
| \<leader>se | \<C-w>=        | 使分割的窗口宽高相等     |
| \<leader>sx | :close\<CR>    | 关闭当先分割的窗口       |
| \<leader>to | :tabnew\<CR>   | 打开新的 tab             |
| \<leader>tx | :tabclose\<CR> | 关闭当前的 tab           |
| \<leader>tn | :tabn\<CR>     | 转到上一个 tab           |
| \<leader>tp | :tabp\<CR>     | 转到下一个 tab           |
| \<leader>sm | :MaximizerToggle\<CR> | 隐藏以及恢复分割的终端 |
| \<leader>e | :NvimTreeToggle\<CR> | 触发文件栏的隐藏以及恢复 |

---

> 插件机制

1. `christoomey/vim-tmux-navigator`
    * 用于分割的窗口，Ctrl +h / j / k / l，可以在不同的窗口跳转
2. `tpope/vim-surround`
    * ysw + “ 或者你想要的键，加到单词两边
    * ds + “ 或者你想要的键，可以删除单词两边
    * cs + “（想要被替换的键） + ‘（想要替换的键）
3. `inkarkat/vim-ReplaceWithRegister`
    * 例如使用 `gr + w`，将剪贴板的sudo apt install telegram-desktop帮助的标签
4. Git
    * \<leader>gc：列出所有 Git 提交（按下 \<cr>进行检出）[“gc”表示 git 提交]
    * \<leader>gfc：列出当前文件/缓冲区的 Git 提交（按下 \<cr> 进行检出）[“gfc”表示 git 文件提交]
    * \<leader>gb：列出Git分支（按下 \<cr> 进行检出）[“gb”表示 git 分支]
    * \<leader>gs：列出当前每个文件的更改，并显示差异预览 [“gs”表示 git 状态]
5. lsp
   * \<leader>rs：重启 lsp 服务
   * gf：展示结果、引用
   * gD：转到定义
   * gd：查看定义并在窗口中编辑
   * gi：跳转到实现
   * \<leader>ca：查看可用的代码操作
   * \<leader>rn：智能重命名
   * \<leader>D：显示该行的问题
   * \<leader>d：显示光标的位置问题的诊断
   * `[d`：跳转到缓冲区中的上一个诊断
   * `]d`：跳转到缓冲区中的下一个诊断
   * `K`：显示光标下内容的文档
   * \<leader>o：参见右手边的轮廓

## tmux

1. tmux new -S Session: come in new terminal
2. tmux detach：将 tmux 产生的会话放入后台
3. tmux attach -t Session: 进入之前放入后台的 session
4. Tmux ls 展示所有的终端
5. `C-a` + `s` 切换终端
6. `C-a` + `Shift-\` 左右分割终端
7. `C-a` + `-‘` 上下分割终端
8. `C-a` + `shift-;` 会话命令，输入 `source-file ~/.tmux.conf` 重新加载文件
9. `C-a` + `h` 缩小左边的会话
10. `C-a` + `l` 缩小右边的会话
11. `C-a` + `j` 缩小上边的会话
12. `C-a` + `k` 缩小下边的会话
13. `C-a` + `r`, `C-a` + `shift-i` 下载配置的 tmp 插件
14. `C-a` + `c` 在当前终端，创建新的会话
15. `C-a` + `0` 展示第一个创建的会话
16. `C-a` + `1` 进入之前创建的第二个会话 …
17. `C-a` + `n` 切换到下一个会话
18. `C-a` + `p` 切换到上一个会话
19. `C-a` + `w` 展示 tmux 到所有会话
20. `C-a` + `m` 隐藏/展示终端会话
21. `C-a` + `[` 在终端使用 vim 模式，可以使用 hjkl，或者 + shift 加速，shift 直接退出该模式
    * 也可以使用 `C-u` 向上翻半页，`C-d` 向下翻半页，`C-f` 翻一整页
    * `C-b` 向上翻一整页，`C-f` 向下翻一整页
    * `v` 可以选择多个文本，使用 `y` 可以复制选择的文本
22. `C-a` + `shift-[` 左右/上下会话互换
23. `C-b` + d:  使终端在后台运行
24. `C-a` + `Shift-i`: 自动下载插件

## 其它配置

### 字体设置

这里使用 [Nerd fonts](https://www.nerdfonts.com/font-downloads) 字体。

### 终端配置

MacOS 下使用的是 iterm2，这里是完整的[配置文件](./terminal_config/mac_iterm2.json)

Windows 下使用的是 powershell，这里是完整的[配置文件](./terminal_config/win_powershell.json)

Linux 下使用的是 konsole，这里是完整的[配置文件](./terminal_config/summer_dark.colorscheme)，你需要将它放置在 `~/.local/share/konsole` 下，然后在 konsole 的设置中选择该主题。

### LSP 配置

详情请见 Mason：<https://github.com/williamboman/mason.nvim>（进入 nvim 后，`:Mason` 进行下载）
