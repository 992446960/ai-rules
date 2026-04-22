# KnowledgeBase

踩坑经验与调试手册的个人知识库，记录**根因分析、规避方案和可复用排查步骤**，供 AI 辅助编程时作为上下文参考。

---

## 目录结构

```
KnowledgeBase/
├── README.md               # 本文件
└── frontend/               # 前端方向
    ├── base/               # 通用前端（框架无关）
    │   └── boundary-keptalive-global-params-id-collision.md
    └── vite/               # Vite 工具链
        └── troubleshooting-vite-dev-server.md
```

---

## 条目索引

### frontend / base — 通用前端

| 文件 | 标题 | 关键词 |
|------|------|--------|
| [boundary-keptalive-global-params-id-collision.md](./frontend/base/boundary-keptalive-global-params-id-collision.md) | 缓存视图 + 全局路由参数 + 双通道拉取 | KeepAlive、route.params、watch、双重请求 |

### frontend / vite — Vite 工具链

| 文件 | 标题 | 关键词 |
|------|------|--------|
| [troubleshooting-vite-dev-server.md](./frontend/vite/troubleshooting-vite-dev-server.md) | Vite 开发服务器端口异常排查手册 | 端口占用、旧进程残留、IPv6、plugin-vue |

---

## 写作规范

每篇文档应包含以下结构（非强制全部出现）：

```
# 标题

## 触发条件   —— 复现场景或错误现象
## 根因       —— 问题的本质原因
## 规避/修复方法
## 举例       —— 具体出现过的业务场景
```

- **文件命名**：全小写，用 `-` 分隔，语义清晰，例如 `xxx-bug-name.md`。
- **分类路径**：按技术方向归入子目录，方向之间尽量正交。
- **解耦原则**：正文与具体业务解耦，只保留通用规律。

---

## 使用方式

在与 AI 协作时，可将相关条目内容直接附加到上下文，辅助模型快速定位同类问题根因、避免重复踩坑。
