<div align=center>
   <h1>NVIM 配置⚙️</h1>
  <img style="margin: 0 auto;" src="https://github.com/fwqaaq/dot/assets/82551626/1964f701-bc7b-40b7-b2b1-3ff0bccd2400" />
</div>

> 本仓库的部分配置参考自 [Youtube Josean Martinez](https://www.youtube.com/watch?v=vdn_pKJUda8&t=3228s)

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/fwqaaq/dot/main/install.sh)"
```

## 依赖要求

- **Neovim** ≥ 0.10（推荐 0.11+，inlay hint、`vim.diagnostic.config.signs.text` 需要）
- **git**（lazy.nvim 自动拉取插件需要）
- **nerd font**（图标显示需要，见下方字体设置）
- **make / gcc**（telescope-fzf-native、LuaSnip 的 jsregexp 编译需要）
- **node**（部分 LSP 与 prettier 需要）

## 插件管理（lazy.nvim）

本配置已从 `packer.nvim`（已废弃）迁移到 [lazy.nvim](https://github.com/folke/lazy.nvim)。首次启动 nvim 会自动克隆 lazy.nvim 并安装所有插件。

常用命令：

| 命令          | 作用                       |
| ------------- | -------------------------- |
| `:Lazy`       | 打开插件管理面板           |
| `:Lazy sync`  | 安装/更新/清理插件         |
| `:Lazy update`| 更新所有插件               |
| `:Lazy clean` | 清理未使用的插件           |
| `:Mason`      | 打开 LSP/格式化器/linter 管理 |
| `:MasonUpdate`| 更新 Mason 注册表          |
| `:checkhealth lazy` | 检查 lazy.nvim 状态  |

插件配置文件位于 `~/.config/nvim/lua/fwqaq/plugins/`，每个文件返回一个 lazy spec，由 `lazy.lua` 中的 `{ import = ... }` 自动加载。

## 使用

> 快捷键，leader 键为 \<space>

| 快捷键      | 等同于                | 作用                     |
| ----------- | --------------------- | ------------------------ |
| jk          | \<esc>                | 退出编辑模式（i 模式下） |
| \<leader>nh | :nohl\<CR>            | 代替 `:` 在终端中的搜索  |
| x           | "\_x                  | 删除光标下的字符         |
| \<leader>+  | \<C-a>                | 自增                     |
| \<leader>-  | \<C-x>                | 自减                     |
| \<leader>sv | \<C-w>v               | 垂直方向分割窗口         |
| \<leader>sh | \<C-w>s               | 水平方向分割窗口         |
| \<leader>se | \<C-w>=               | 使分割的窗口宽高相等     |
| \<leader>sx | :close\<CR>           | 关闭当先分割的窗口       |
| \<leader>to | :tabnew\<CR>          | 打开新的 tab             |
| \<leader>tx | :tabclose\<CR>        | 关闭当前的 tab           |
| \<leader>tn | :tabn\<CR>            | 转到上一个 tab           |
| \<leader>tp | :tabp\<CR>            | 转到下一个 tab           |
| \<leader>sm | :MaximizerToggle\<CR> | 隐藏以及恢复分割的终端   |
| \<leader>e  | :NvimTreeToggle\<CR>  | 触发文件栏的隐藏以及恢复 |
| \<leader>fm | conform format        | 格式化当前缓冲区         |
| \<leader>l  | nvim-lint try_lint    | 手动触发当前文件的 lint  |
| \<leader>rs | :LspRestart\<CR>      | 重启 LSP 服务            |

---

> 插件机制

1. `christoomey/vim-tmux-navigator`
   - 用于分割的窗口，`Ctrl + h / j / k / l`，可以在不同的窗口（包括 tmux pane）跳转
2. `kylechui/nvim-surround`（替代已弃用的 `tpope/vim-surround`，纯 lua 实现）
   - `ys` + motion + 字符，例如 `ysw"` 在单词两边加上引号
   - `ds` + 字符，例如 `ds"` 删除两边的引号
   - `cs` + 旧字符 + 新字符，例如 `cs"'` 把双引号换成单引号
3. `inkarkat/vim-ReplaceWithRegister`
   - `gr` + motion，将寄存器（剪贴板）内容替换到目标范围。例如 `grw` 把当前单词替换为剪贴板内容
4. **Copilot**（`zbirenbaum/copilot.lua` + `copilot-cmp`）
   - 通过 nvim-cmp 弹窗显示 Copilot 建议（不是 ghost text，避免冲突）
   - 首次使用执行 `:Copilot auth` 进行登录
   - `:Copilot status` 查看 Copilot 状态
5. Git（telescope）
   - \<leader>gc：列出所有 Git 提交（按下 \<cr> 进行检出）
   - \<leader>gfc：列出当前文件/缓冲区的 Git 提交
   - \<leader>gb：列出 Git 分支（按下 \<cr> 进行检出）
   - \<leader>gs：列出当前每个文件的更改，并显示差异预览
6. LSP（已移除 lspsaga，全部使用 Neovim 内置 `vim.lsp.buf.*` / `vim.diagnostic.*`）
   - `gf`：查看引用（references）
   - `gD`：转到声明（declaration）
   - `gd`：转到定义（definition）
   - `gi`：跳转到实现
   - \<leader>ca：查看/触发代码操作
   - \<leader>rn：智能重命名
   - \<leader>D / \<leader>d：浮窗显示当前行/光标处的诊断
   - `[d` / `]d`：跳转到上一个/下一个诊断
   - `K`：浮窗显示光标处的文档（hover）
   - \<leader>o：通过 Telescope 显示文档符号（document symbols）
   - **TypeScript 专属**（`ts_ls` 附加时启用）：
     - \<leader>oi：组织 imports（`source.organizeImports` 代码操作）
     - \<leader>ru：移除未使用的 imports（`source.removeUnused`）
7. 自动补全（`hrsh7th/nvim-cmp`）
   - `<C-Space>`：手动触发补全
   - `<C-j>` / `<C-k>`：下一项 / 上一项
   - `<Tab>` / `<S-Tab>`：在补全/snippet 跳转中前后移动
   - `<C-f>` / `<C-b>`：滚动文档浮窗
   - `<CR>`：确认所选项（不会自动选中第一项，避免误触）
   - `<C-e>`：取消补全
   - 补全源优先级：`copilot` > `nvim_lsp` > `luasnip` > `signature_help` > `buffer` / `path`
8. 格式化与 Lint
   - 格式化：`stevearc/conform.nvim`，保存时自动格式化（`format_on_save`），手动 \<leader>fm
   - Lint：`mfussenegger/nvim-lint`，在 `BufEnter` / `BufWritePost` / `InsertLeave` 自动运行；手动 \<leader>l
   - 已配置的格式化器：`prettier` (js/ts/css/html/json/yaml/md/...)、`stylua` (lua)、`rustfmt` (rust)、`gofmt` (go)、`clang-format` (c/cpp)
   - 已配置的 linter：`eslint_d`（js/ts/jsx/tsx/svelte/vue）
9. telescope
   - \<leader>ff：查找当前目录的所有文件
   - \<leader>fb：按照当前的目录结构打开文件
   - \<leader>fs：在当前目录中实时搜索字符串（live grep）
   - \<leader>fc：搜索光标下的字符串
   - \<leader>fh：列出所有 help tags

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
    - 也可以使用 `C-u` 向上翻半页，`C-d` 向下翻半页，`C-f` 翻一整页
    - `C-b` 向上翻一整页，`C-f` 向下翻一整页
    - `v` 可以选择多个文本，使用 `y` 可以复制选择的文本
22. `C-a` + `shift-[` 左右/上下会话互换
23. `C-b` + d: 使终端在后台运行
24. `C-a` + `Shift-i`: 自动下载插件

## 其它配置

### 字体设置

这里使用 [Nerd fonts](https://www.nerdfonts.com/font-downloads) 字体，在 VSCode 中使用的是 [MesloLGS NF](https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#manual-font-installation) 字体。

### 终端配置

MacOS 下使用的是 iterm2，这里是完整的[配置文件](./terminal_config/mac_iterm2.json)

Windows 下使用的是 powershell，这里是完整的[配置文件](./terminal_config/win_powershell.json)，点击 powersell 配置下的 JSON 按钮，将 JSON 文件换成该配置文件即可。

Linux 下使用的是 konsole，这里是完整的[配置文件](./terminal_config/summer_dark.colorscheme)，你需要将它放置在 `~/.local/share/konsole` 下，然后在 konsole 的设置中选择该主题。

### LSP 配置

详情请见 Mason：<https://github.com/mason-org/mason.nvim>（进入 nvim 后，`:Mason` 进行下载）。

> 注意：Mason 仓库已从 `williamboman/mason.nvim` 迁移到 `mason-org/mason.nvim`，本配置已使用新地址。

`:Mason` 中默认安装的 LSP 服务器：

```
cssls, cssmodules_ls, denols, emmet_ls, gopls, html, jsonls, lua_ls,
marksman, rust_analyzer, tailwindcss, taplo, ts_ls, volar, yamlls, buf_ls
```

> 注意：`tsserver` 已重命名为 `ts_ls`，`bufls` 已重命名为 `buf_ls`（lspconfig 的命名变更）。

通过 `mason-tool-installer` 自动安装的格式化/lint 工具：

```
prettier, stylua, eslint_d, clang-format
```

### 故障排查

| 现象 | 解决方法 |
| --- | --- |
| 启动报错找不到 colorscheme | 等 lazy 第一次安装完成后重启 nvim |
| `:checkhealth` 报告 LuaSnip jsregexp 缺失 | 进入 `~/.local/share/nvim/lazy/LuaSnip` 执行 `make install_jsregexp` |
| Copilot 不工作 | `:Copilot auth` 重新认证；确认 `:Copilot status` 显示 Ready |
| TypeScript 项目误启动 deno | 当前目录无 `deno.json` 时 `denols` 不会附加；冲突时检查 `:LspInfo` |
| eslint_d 报错 | 项目根目录需要 `.eslintrc*` 或 `eslint.config.js` |
