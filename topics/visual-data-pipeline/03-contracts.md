# 核心契约

本文档规定多终端协作时必须遵守的稳定边界。实际 TypeScript 和 Zod Schema 由 `packages/contracts` 提供，以代码为可执行来源；本文负责解释语义。

## 项目文件

```ts
interface PipelineProject {
  format: "visual-data-pipeline";
  formatVersion: 1;
  id: string;
  name: string;
  createdAt: string;
  updatedAt: string;
  nodes: PipelineNode[];
  edges: PipelineEdge[];
  viewport?: { x: number; y: number; zoom: number };
}
```

项目文件不得包含：

- 原始文件内容。
- Blob URL 或浏览器临时句柄。
- 执行缓存和预览数据。
- 密钥、令牌或远程连接信息。

## 节点

```ts
type NodeKind =
  | "input.csv"
  | "input.json"
  | "input.xlsx"
  | "transform.select"
  | "transform.cast"
  | "transform.filter"
  | "transform.derive"
  | "transform.sort"
  | "transform.deduplicate"
  | "aggregate.group"
  | "combine.join"
  | "output.csv"
  | "output.json"
  | "output.xlsx";

interface PipelineNode {
  id: string;
  kind: NodeKind;
  position: { x: number; y: number };
  label: string;
  config: unknown;
}
```

每种节点必须注册：

- `kind` 和显示信息。
- 输入、输出端口定义。
- 配置 Zod Schema。
- 默认配置。
- 配置表单或表单描述。
- 执行器。
- 最少一个成功测试和一个失败测试。

## 数据模型

```ts
type CellValue = string | number | boolean | null | Date;
type ColumnType = "string" | "number" | "boolean" | "date" | "datetime" | "unknown";

interface DataSchema {
  columns: Array<{
    id: string;
    name: string;
    type: ColumnType;
    nullable: boolean;
  }>;
}
```

引擎内部数据表可以使用第三方高效结构，但跨 Worker 消息和公共 API 必须转换为项目定义的 DTO。

## 边与图规则

- 边连接输出端口和输入端口。
- 普通转换节点只能有一个数据输入。
- Join 节点必须有 `left` 和 `right` 两个输入。
- 输出节点不能有数据输出。
- MVP 不允许形成环。
- 删除节点必须同时删除关联边。
- 无法从输入节点到达的节点产生错误诊断。

## 执行状态

```ts
type NodeRunStatus =
  | "idle"
  | "queued"
  | "running"
  | "succeeded"
  | "warning"
  | "failed"
  | "cancelled";
```

每次运行生成新的 `runId`。UI 必须忽略不属于当前 `runId` 的迟到消息。

## 诊断

```ts
interface Diagnostic {
  code: string;
  severity: "info" | "warning" | "error";
  message: string;
  nodeId?: string;
  fieldPath?: string;
  rowNumber?: number;
  details?: Record<string, string | number | boolean | null>;
}
```

- `code` 必须稳定，UI 不解析 message 文本决定行为。
- 错误阻止相关节点执行；警告允许完成。
- 诊断不得包含完整敏感数据行。

## 契约变更流程

1. 在 `decisions.md` 增加提议和原因。
2. 更新本文档及 `packages/contracts`。
3. 更新契约测试和项目文件迁移测试。
4. 通知所有终端重新同步基线。
5. 未经协调，不允许各模块创建同义但不兼容的类型。
