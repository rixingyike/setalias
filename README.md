# setalias

AI 时代工程师常用快捷工具脚本，一键设置，每天使用。

## 使用前配置
- 在仓库根执行：`./setup.sh --project-root /绝对/路径/到你的项目根目录`
- 不传参数时默认项目根：`$HOME/work/yishulun_blog_mdandcode`
- 验证：`alias new` 显示 `'$HOME/.new.sh'`；`grep SETALIAS_PROJECT_ROOT ~/.setaliasrc`

### 常用命令
- `new "标题"` 在 `SETALIAS_PROJECT_ROOT/src/blog/<当前年份>/` 创建文章
- `post` 在 `SETALIAS_PROJECT_ROOT` 目录内执行自动提交
- `fetch` 拉取远端更新（带分支检测与安全策略）
- `push "commit message"` 推送当前分支（无暂存更改时跳过 commit）
- `pull` 仅快进拉取（`--ff-only`）
- `open_typora /path/to/file.md` 跨平台打开 Typora

### 可选：配置 Git 用户信息
```
git config --global user.email "9830131@qq.com"
git config --global user.name "李艺"
```
