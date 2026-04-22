# Vite 开发服务器端口异常排查手册

## 适用场景

当本地前端启动了多个 Vite 开发服务器，出现下面这类现象时，优先按本手册排查：

- `http://localhost:5173/` 报 `.vue` 文件解析错误
- `http://localhost:5174/` 或其他自动切换端口正常
- 报错内容包含 `Install @vitejs/plugin-vue to handle .vue files`
- `vite.config.ts` 中已经配置了 `plugins: [vue()]`
- `package.json` 中已经安装了 `@vitejs/plugin-vue`

典型错误：

```text
[plugin:vite:import-analysis] Failed to parse source for import analysis because the content contains invalid JS syntax.
Install @vitejs/plugin-vue to handle .vue files.
```

## 根因判断

如果配置和依赖都正确，但 `localhost:5173` 仍然报错，常见根因是：

1. `5173` 端口上残留了旧的 Vite 或 Node 进程。
2. 新启动的 `pnpm dev` 因端口占用自动切换到 `5174`。
3. 浏览器访问 `localhost:5173` 时，命中了旧进程，而不是当前配置正确的新进程。
4. 在 macOS 上，`localhost` 可能优先解析到 IPv6 `::1`，因此会出现 `127.0.0.1:5173` 正常、`localhost:5173` 异常的情况。

这类问题不是 `App.vue` 模板语法错误，也不是必然需要重新安装依赖。重点是确认当前端口实际由哪个进程提供服务。

## 快速处理步骤

### 1. 查看 5173 监听进程

```bash
lsof -nP -iTCP:5173 -sTCP:LISTEN
```

重点看 `PID` 和 `NAME`：

```text
COMMAND   PID   USER   NAME
node      24563 Clare  TCP *:5173 (LISTEN)
node      81346 Clare  TCP localhost:5173 (LISTEN)
```

如果同一个端口出现多个 `node` 监听，尤其是同时存在 `*:5173` 和 `localhost:5173`，需要进一步确认是否有旧进程残留。

### 2. 查看进程启动时间和命令

```bash
ps -p 24563,81346 -o pid,ppid,etime,command
```

示例：

```text
PID    PPID  ELAPSED        COMMAND
81346  81319 12-20:48:20    node .../node_modules/.bin/vite --port 5173
24563  24550 03:16          node .../vite/bin/vite.js
```

如果某个 Vite 进程已经运行了很久，并且不是当前终端刚启动的 `pnpm dev`，它通常就是异常来源。

### 3. 验证 IPv4、IPv6、localhost 的返回是否一致

```bash
curl -sS --max-time 3 http://127.0.0.1:5173/src/App.vue
curl -g -sS --max-time 3 'http://[::1]:5173/src/App.vue'
curl -sS --max-time 3 http://localhost:5173/src/App.vue
```

正常情况下，返回内容应该包含 Vue 插件编译后的模块代码，例如：

```text
plugin-vue:export-helper
```

如果返回的是 Vite 错误 HTML，且包含 `Failed to parse source`，说明该地址命中了异常 Vite 进程。

### 4. 停止异常旧进程

先停止确认异常的子进程：

```bash
kill 81346
```

如果父进程仍然存在并重新拉起子进程，再停止父进程：

```bash
kill 81319
```

不要直接复制示例 PID。实际执行时必须替换为 `lsof` 和 `ps` 查到的本机 PID。

### 5. 重新验证

```bash
lsof -nP -iTCP:5173 -sTCP:LISTEN
curl -sS --max-time 3 http://localhost:5173/src/App.vue | grep -q 'plugin-vue:export-helper'
curl -sS --max-time 3 http://localhost:5173/src/App.vue | grep -q 'Failed to parse source'
```

预期结果：

- `lsof` 中 `5173` 只剩当前需要保留的 Vite 进程。
- 第一个 `grep` 退出码为 `0`。
- 第二个 `grep` 退出码为 `1`，表示没有匹配到错误文本。

## 命令说明

### `lsof -nP -iTCP:5173 -sTCP:LISTEN`

这个命令用于查看哪个进程正在监听 `5173` 端口。

| 参数 | 含义 |
|------|------|
| `lsof` | list open files。macOS/Linux 中网络端口也属于进程打开的资源 |
| `-n` | 不把 IP 反查成域名，输出更快、更直接 |
| `-P` | 不把端口号转换成服务名，直接显示数字端口 |
| `-iTCP:5173` | 只查看 TCP 协议中使用 `5173` 端口的连接 |
| `-sTCP:LISTEN` | 只查看正在监听的服务端进程 |

常用输出列：

| 列 | 含义 |
|----|------|
| `COMMAND` | 进程名，Vite 通常是 `node` |
| `PID` | 进程 ID，`kill` 时使用 |
| `USER` | 进程所属用户 |
| `NAME` | 监听地址和端口 |

### `ps -p <PID> -o pid,ppid,etime,command`

这个命令用于判断进程是不是旧进程。

| 字段 | 含义 |
|------|------|
| `pid` | 当前进程 ID |
| `ppid` | 父进程 ID |
| `etime` | 已运行时间 |
| `command` | 启动命令 |

如果 `etime` 显示已经运行了数天，而当前终端刚执行过 `pnpm dev`，通常说明它是残留进程。

### `curl http://localhost:5173/src/App.vue`

这个命令直接请求 Vite 对 `.vue` 文件的转换结果。

判断方式：

- 正常：返回 JavaScript 模块，内容包含 `plugin-vue:export-helper`
- 异常：返回错误 HTML，内容包含 `Failed to parse source`

## 预防建议

- 每次只保留一个前端开发服务器，停止不用的终端进程。
- 看到 `Port 5173 is in use, trying another one...` 时，不要只打开新端口，也要确认旧的 `5173` 是否仍然需要。
- 结束开发时优先在运行 `pnpm dev` 的终端按 `Ctrl+C`，不要直接关闭终端窗口。
- 下次遇到 `localhost` 异常但 `127.0.0.1` 正常时，优先检查 IPv6 `::1` 上是否有旧监听。

## 本次问题复盘

本次故障中：

- `5173` 上同时存在两个 Node/Vite 监听进程。
- 一个旧进程监听 `localhost:5173`，已经运行 12 天。
- 新进程监听 `*:5173`，配置正常。
- 浏览器访问 `localhost:5173` 命中了旧进程，因此 `.vue` 文件未经过当前 Vue 插件编译。
- 停止旧进程后，`localhost:5173/src/App.vue` 返回编译后的 Vue 模块，问题消失。
