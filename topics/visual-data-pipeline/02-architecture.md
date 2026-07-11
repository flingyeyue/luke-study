# 技术架构

## 技术选择

- 包管理与工作区：pnpm workspace。
- 应用：React、TypeScript、Vite。
- 画布：React Flow。
- 状态管理：Zustand，历史记录单独建模。
- 表格预览：支持行列虚拟化的 React 表格方案。
- CSV：Papa Parse；XLSX：SheetJS；JSON 使用浏览器原生解析并增加结构校验。
- 表格转换：优先封装成熟的数据处理库；项目契约不得暴露第三方类型。
- 表达式：受限表达式解析器，不使用 `eval` 或 `new Function`。
- 后台执行：Web Worker。
- Schema：Zod，用于运行时校验和类型推导。
- 测试：Vitest、Testing Library、Playwright。

依赖版本在项目初始化时锁定。引入依赖前检查许可证、包体积、浏览器兼容性和维护状态。

## 仓库结构

```text
project/
├── apps/
│   └── web/
│       ├── src/app/
│       ├── src/features/canvas/
│       ├── src/features/node-config/
│       ├── src/features/preview/
│       └── src/features/project-files/
├── packages/
│   ├── contracts/          # 唯一共享数据契约
│   ├── pipeline-engine/    # 纯执行计划、转换和诊断
│   ├── file-adapters/      # CSV/JSON/XLSX 导入导出
│   └── test-fixtures/
├── tests/e2e/
└── tooling/
```

## 模块边界

### contracts

- 定义项目文件、节点、端口、字段、诊断和执行结果。
- 不依赖 React、文件解析库或数据转换库。
- 修改公共契约需要由主协调终端审核。

### pipeline-engine

- 校验图结构并生成拓扑执行计划。
- 调度节点执行器。
- 实现取消、诊断、结果摘要和确定性执行。
- 不读写 DOM、文件系统或 localStorage。

### file-adapters

- 将浏览器 File 转换为统一数据表。
- 将统一数据表导出为 Blob。
- 负责编码、分隔符、工作表和格式错误。
- 不关心画布和节点 UI。

### web

- 管理画布、配置表单、预览、命令和用户反馈。
- 通过 Worker 客户端调用执行引擎。
- 不在 React 组件里实现转换算法。

## 执行流程

```text
项目 JSON
  → Schema 校验
  → 图结构校验
  → 拓扑排序
  → Worker 执行节点
  → 中间结果缓存
  → 进度/诊断消息
  → 数据预览或文件导出
```

## 性能策略

- 文件解析和节点执行放入 Web Worker。
- UI 只接收分页预览、Schema 和统计信息，不复制完整数据集。
- 节点结果按执行版本缓存；上游配置变化时使下游缓存失效。
- 数据表与日志使用虚拟化渲染。
- 用户取消后停止后续节点，并忽略过期 Worker 消息。
- 性能测试使用固定生成数据，不把主观感受作为结果。

## 安全策略

- 禁止执行任意代码。
- 表达式只允许白名单运算符和字段引用。
- Spreadsheet 导出时防止公式注入：以 `=`, `+`, `-`, `@` 开头的非公式文本进行转义。
- 项目文件和导入数据分别校验，不信任扩展名。
- 错误消息限制数据样例长度并进行脱敏。

## 状态分层

- `project state`：节点、边、视口和项目元数据，可撤销重做。
- `runtime state`：执行状态、进度、缓存和诊断，不进入撤销历史。
- `ui state`：面板尺寸、选中页签和主题，可保存在 localStorage。
- `source state`：用户当前会话选择的 File 对象，只保存在内存。

这种分层用于避免执行进度污染项目文件和撤销历史。
