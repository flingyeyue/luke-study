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

## 技术栈清单

| 层次 | 技术 | 用途 | 选择理由 | 状态 |
|---|---|---|---|---|
| 运行环境 | 当前 Active LTS Node.js | 构建、测试和工具脚本 | 团队支持周期稳定 | 初始化时锁定 |
| 包管理 | pnpm workspace + Corepack | monorepo 和依赖锁定 | 安装快，工作区边界清晰 | 已冻结 |
| 语言 | TypeScript strict | 全部业务代码与契约 | 提前发现跨模块类型错误 | 已冻结 |
| Web 框架 | React | 工作区和复杂交互 UI | 生态成熟，适合组件化编辑器 | 已冻结 |
| 构建工具 | Vite | 开发服务器和生产构建 | ESM 开发体验和 Worker 支持良好 | 已冻结 |
| 流程画布 | `@xyflow/react` | 节点、边、选择、缩放和视口 | 原生覆盖节点编辑器核心交互 | 已冻结 |
| 状态管理 | Zustand | project、runtime 和 UI 状态 | API 小，便于按状态域拆分 | 已冻结 |
| 运行时校验 | Zod | 项目文件、节点配置和 Worker 消息 | Schema 与 TypeScript 类型可保持一致 | 已冻结 |
| 数据预览 | TanStack Table + TanStack Virtual | 表头、列模型和双向虚拟化 | headless，便于保持产品定制能力 | 已冻结 |
| CSV | Papa Parse | CSV 流式解析和导出 | 浏览器支持成熟，便于分块处理 | 已冻结 |
| Excel | SheetJS Community Edition | XLSX 导入和导出 | 浏览器端文件能力覆盖 MVP | 原型后确认 |
| JSON | 原生 JSON + 自定义规范化 | JSON 对象数组输入输出 | 减少不必要依赖 | 已冻结 |
| 表格运算 | 自有节点接口 + 候选成熟库适配层 | 筛选、排序、聚合和 Join | 防止第三方类型渗透公共契约 | 原型后确认 |
| 表达式 | 受限表达式解析器 | 筛选和计算字段 | 避免执行任意 JavaScript | 原型后确认 |
| 后台线程 | Web Worker | 文件解析和流水线执行 | 避免阻塞界面主线程 | 已冻结 |
| 单元测试 | Vitest | contracts、engine、adapters 和组件测试 | 与 Vite/ESM 工具链一致 | 已冻结 |
| 组件测试 | Testing Library | 用户行为导向的 React 测试 | 减少实现细节耦合 | 已冻结 |
| 端到端测试 | Playwright | Chromium/Firefox/WebKit 主流程验证 | 支持真实文件上传和下载验证 | 已冻结 |
| 代码质量 | ESLint + Prettier | 静态检查和格式化 | 统一多终端输出 | 已冻结 |

“原型后确认”的依赖必须在阶段 1 结束前形成 ADR，记录许可证、构建体积、API 能力、性能样例和未采用方案。未经 ADR 不得直接进入共享包。

## 版本与环境策略

- 在 `.nvmrc` 或等效文件锁定 Node.js 主版本，在 `package.json` 声明 `engines` 和 `packageManager`。
- 提交 `pnpm-lock.yaml`，CI 使用冻结锁文件安装。
- 依赖版本不使用 `latest`、`*` 或未限制范围。
- 浏览器目标先定为当前稳定版 Chromium、Firefox 和 WebKit；阶段 1 用 Playwright 实测后记录最低支持范围。
- 不依赖 Node.js API 的共享包必须能在浏览器和 Web Worker 环境构建。
- 开发和生产构建都启用 TypeScript strict，不通过降低检查级别绕过错误。

## 依赖准入检查

新增运行时依赖前必须回答：

1. 标准 Web API 或现有依赖能否完成任务？
2. 许可证是否允许公司项目使用？
3. 是否支持 ESM、Web Worker 和目标浏览器？
4. 是否会把 Node.js polyfill 或大体积依赖带入浏览器？
5. 是否能够通过项目自有接口隔离，未来可替换？
6. 是否有最小原型和自动化测试证明关键能力？

## 官方参考

- React Flow：https://reactflow.dev/
- TanStack Table 虚拟化：https://tanstack.com/table/latest/docs/guide/virtualization
- TanStack Virtual：https://tanstack.com/virtual/latest
- Vite：https://vite.dev/
- Vitest：https://vitest.dev/
- Playwright：https://playwright.dev/
- Papa Parse：https://www.papaparse.com/
- SheetJS：https://docs.sheetjs.com/
- Zod：https://zod.dev/

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
