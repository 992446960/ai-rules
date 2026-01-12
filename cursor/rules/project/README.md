# 项目级规则（Project Rules）

本目录下的规则用于约束：
- 本项目的技术选型
- 代码风格与架构设计
- AI 编程助手（Cursor）行为
- 日志记录与可追溯性

## 规则优先级
1. 本目录规则 > Cursor 默认规则
2. 项目级规则 > 用户习惯
3. 架构稳定性 > 开发速度

## 规则文件说明
- base.rules.md：通用行为、AI 协作、修改原则
- tech-stack.rules.md：技术栈与版本强约束
- code-style.rules.md：代码与组件规范
- architecture.rules.md：项目结构与设计原则
- api.rules.md：API、状态管理、请求规范
- ui-style.rules.md：UI、样式、组件使用
- quality.rules.md：质量、异常、性能
- git.rules.md：提交与协作
- log.rules.md：开发日志（2 级）

所有代码生成、修改、重构必须遵循上述规则。