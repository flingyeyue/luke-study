# 使用与功能指南

## 1. 项目用途

可视化数据转换流水线是一个完全运行在浏览器中的表格数据处理工具。当前工作区可以选择本地 CSV，通过画布组织转换、聚合和双输入 Join，在 Web Worker 中执行，预览结果，并下载 CSV。项目不需要账号、数据库或后端服务，源文件内容不会由应用上传到服务器。

适合的场景：

- 对 CSV 做字段选择、改名、类型转换、筛选、计算、排序和去重。
- 按一个或多个字段分组并计算数量、合计、平均值、最小值或最大值。
- 将两份 CSV 按一个或多个键做 inner Join 或 left Join。
- 保存不含原始数据的流水线定义，以后重新打开继续编辑。
- 在不上传业务数据的前提下快速验证数据清洗规则。

当前不是电子表格、数据库客户端或云端任务平台。它不提供登录、协作、定时任务、SQL、任意 JavaScript、图表或远程保存。

## 2. 启动方式

环境要求：Node.js 24、Corepack 和 pnpm 11.11.0。

```bash
cd /home/lucas/code/luke/project
corepack enable pnpm
pnpm install --frozen-lockfile
pnpm dev
```

打开 Vite 输出的本地地址。开发服务器通常使用 `http://localhost:5173`；以终端实际输出为准。

生产构建：

```bash
pnpm build
```

构建结果位于 `apps/web/dist/`。这是浏览器应用，必须通过 HTTP 静态服务器访问，不能依赖直接双击 `index.html`。

## 3. 工作区界面

### 顶部命令栏

- **新建项目**：清空画布。有未保存修改时先确认。
- **打开项目**：打开 `.json` 或 `.vdp.json` 项目定义。文件必须符合格式版本 1。
- **保存项目**：下载版本化项目 JSON。项目文件只含节点、边、位置和配置，不含 CSV 行或浏览器 `File` 对象。
- **恢复草稿**：存在浏览器本地草稿时显示。草稿也只保存项目定义。
- **选择 CSV**：把文件绑定到一个尚未绑定的 CSV 输入节点；没有可用输入节点时自动创建一个，并立即解析和预览源数据。
- **运行**：执行当前完整图。至少选择一份 CSV 后启用。
- **导出**：把当前预览结果下载为 `pipeline-output.csv`。
- **已保存/未保存**：表示画布和配置是否相对最近保存状态有修改。

### 节点库和画布

- 单击节点库项目会创建节点；也可以拖到画布指定位置。
- 新节点自动成为当前选中节点，右侧配置面板随之切换。
- 普通转换节点有一个 `in` 输入和一个 `out` 输出。
- Join 有 `left`、`right` 两个输入端口和一个 `out` 输出。
- 输出节点只有输入端口。
- 新增普通处理节点时，系统会尝试从最近的未连接末端自动连线；新增 Join 时会尝试把最近两个末端依次连接到 left/right。
- 画布拒绝自连接、环、无效端口、重复边和已占用的输入端口。
- 工具栏支持撤销、重做、放大、缩小和适配视图。删除选中节点或边可使用 `Delete` 或 `Backspace`。

移动视口中，节点库显示为顶部横向滚动工具带，配置面板位于画布下方，功能与桌面端一致。

### 配置面板

配置面板默认使用**可视化**模式，并保留 **JSON** 模式：

- 可视化模式为全部输入、转换、聚合、Join 和输出节点提供文本框、下拉框、复选框及规则增删按钮。
- 筛选和计算字段通过可嵌套的表达式控件选择固定值、字段、单项判断或两项运算（加减乘除/比较）。
- 单字段输入会根据最近一次运行结果提供“字段名 + 字段 ID”候选；也可以直接输入稳定 ID。
- 切换到 JSON 会显示与表单同步的完整配置；有效 JSON 可以切回可视化模式，无效 JSON 会停留在当前模式并显示契约错误。
- 修改后必须单击**应用**；只有通过对应 Zod Schema 校验的配置才会写入节点。

### 底部运行面板

- **数据**：显示当前选中且已执行节点的最多 1,000 行预览和总行数；表格采用窗口化渲染。完整运行结束后，可单击输入、处理或输出节点切换查看各阶段结果。
- **字段**：显示当前预览数据的字段名、稳定字段 ID、推断类型以及是否可空。
- **日志**：按收到顺序显示 Worker 事件类型。
- **错误**：显示错误代码和消息。

节点颜色状态包括空闲、排队中、运行中、成功、警告、失败和已取消。

## 4. CSV 导入和字段 ID

CSV 输入配置默认值：

```json
{
  "sourceId": "source",
  "delimiter": "auto",
  "header": true,
  "encoding": "utf-8",
  "skipEmptyLines": true
}
```

`delimiter` 支持 `auto`、`,`、`;`、制表符和 `|`。当前只支持 UTF-8。`header: true` 表示第一行是字段名。

选择 CSV 后，应用会先在 Worker 中单独执行该输入节点。底部数据表会立即显示解析后的字段结构、总行数和前 1,000 行，不需要先构建完整流水线或单击**运行**。完整图运行成功后，Worker 会缓存每个成功节点的结果；单击画布中的已执行节点即可把数据和字段页切换到该节点。尚未执行或不属于最近一次运行的节点没有可预览数据。

字段配置使用稳定列 ID，而不是只使用显示名称。ID 由字段名转为小写 slug，再附加从 1 开始的列序号。例如：

| CSV 字段顺序 | 字段名       | 列 ID          |
| ------------ | ------------ | -------------- |
| 1            | `order_id`   | `order-id-1`   |
| 2            | `order_date` | `order-date-2` |
| 3            | `region`     | `region-3`     |

先运行一次输入并查看**字段**页签，可以确认名称和类型；列 ID 暂不直接显示在界面中，需要按上述规则确定。字段名中的非字母数字字符会变成连字符，空名称使用 `column`。

## 5. 节点功能和配置

### 选择与重命名 `transform.select`

选择字段、调整输出顺序并改名。至少需要一个字段。

```json
{
  "columns": [
    { "sourceColumnId": "order-id-1", "outputName": "订单号" },
    { "sourceColumnId": "amount-5", "outputName": "金额" }
  ]
}
```

### 类型转换 `transform.cast`

目标类型支持 `string`、`number`、`boolean`、`date` 和 `datetime`。失败策略：

- `fail`：节点失败并返回诊断。
- `null`：失败值改为 null，并产生警告。
- `keep-original`：保留原值，并产生警告。

```json
{
  "rules": [
    { "columnId": "amount-5", "targetType": "number", "onError": "null" },
    { "columnId": "order-date-2", "targetType": "date", "onError": "fail" }
  ]
}
```

日期会严格检查实际日历值，`2026-02-31` 不会被自动修正为三月日期。

### 筛选 `transform.filter`

筛选条件是受限表达式 AST，不执行 JavaScript 字符串。新建筛选节点默认显示“字段等于固定值”，可以直接选择等于、不等于、大小比较、并且、或者或嵌套算术：

```json
{
  "predicate": {
    "type": "binary",
    "operator": "neq",
    "left": { "type": "column", "columnId": "status-4" },
    "right": { "type": "literal", "value": "cancelled" }
  }
}
```

支持 `eq`、`neq`、`gt`、`gte`、`lt`、`lte`、`and`、`or`、`add`、`subtract`、`multiply` 和 `divide`，以及字面量、列引用和空值判断。比较不会在数字和字符串间做隐式转换。

### 计算字段 `transform.derive`

使用同一受限表达式添加一列。新建节点默认显示“字段 + 0”，可以直接从运算符选择加、减、乘、除；左右值都可以继续切换为字段、固定值或嵌套运算：

```json
{
  "outputName": "含税金额",
  "expression": {
    "type": "binary",
    "operator": "multiply",
    "left": { "type": "column", "columnId": "amount-5" },
    "right": {
      "type": "binary",
      "operator": "add",
      "left": { "type": "literal", "value": 1 },
      "right": { "type": "column", "columnId": "tax-rate-6" }
    }
  }
}
```

除零、非有限数值或类型不匹配会产生诊断。

### 排序 `transform.sort`

支持稳定多字段排序。`nulls` 独立指定空值在最前或最后，不随升降序反转。

```json
{
  "rules": [
    { "columnId": "region-3", "direction": "asc", "nulls": "last" },
    { "columnId": "amount-5", "direction": "desc", "nulls": "last" }
  ]
}
```

### 去重 `transform.deduplicate`

按一个或多个字段组成的复合键去重，`keep` 为 `first` 或 `last`。

```json
{
  "columnIds": ["order-id-1"],
  "keep": "first"
}
```

数字 `1` 和字符串 `"1"` 被视为不同键。

### 分组统计 `aggregate.group`

聚合操作支持 `count`、`sum`、`avg`、`min` 和 `max`。

```json
{
  "groupBy": ["region-3"],
  "aggregates": [
    { "operation": "count", "outputName": "订单数" },
    { "operation": "sum", "columnId": "amount-5", "outputName": "销售额" },
    { "operation": "avg", "columnId": "amount-5", "outputName": "平均金额" }
  ]
}
```

无 `columnId` 的 count 统计行数；带列的 count 只统计非空值。sum/avg 只接受数字，聚合时忽略 null。

### 关联 `combine.join`

支持 `inner` 和 `left`，左右键数量和类型必须一致。

```json
{
  "joinType": "inner",
  "leftKeys": ["region-3"],
  "rightKeys": ["region-1"],
  "rightColumnPrefix": "region."
}
```

- inner 只保留匹配行；left 还保留左侧未匹配行，并以 null 填充右列。
- null 键不参与匹配。
- 右侧重复键会为每个匹配结果生成一行。
- 左右同名字段时，右字段增加 `rightColumnPrefix`。
- 数据角色由边连接的 `left`/`right` 端口决定，不由节点创建顺序或边数组顺序决定。

### 输出节点

画布提供 CSV 输出和 JSON 输出节点，它们用于表达图的末端和保存配置。当前顶部**导出**按钮始终把当前预览下载为 CSV：

```json
{
  "delimiter": ",",
  "includeHeader": true,
  "fileName": "output.csv"
}
```

CSV/XLSX 适配器会把以空白后 `=`、`+`、`-`、`@` 开头的字符串前置单引号，降低电子表格公式注入风险；数值负数不会被修改。

## 6. 常用操作流程

### 单输入清洗和导出

1. 单击**选择 CSV**并选择文件，系统创建 CSV 输入并立即显示源数据表。
2. 依次添加类型转换、筛选、计算字段、排序或其他节点。
3. 逐个选中节点，在可视化表单中配置；需要直接编辑完整结构时切换到 JSON。完成后单击**应用**。
4. 添加 CSV 输出节点。
5. 单击**运行**，查看数据、字段、日志和错误；单击不同节点比较每个处理阶段的结果。
6. 单击**导出**下载当前预览结果。

仓库中的 `project/packages/test-fixtures/data/orders-small.csv` 可用于练习。

### 双输入 Join

1. 选择第一份 CSV。
2. 从节点库添加第二个 CSV 输入，再次选择 CSV；文件会绑定到尚未绑定的输入节点。
3. 确保两个输入分支都是未连接末端，然后添加 Join，检查 left/right 连线。
4. 配置左右列 ID、Join 类型和冲突前缀并应用。
5. 添加输出节点、运行并检查结果。

### 保存、打开和恢复

1. 画布改变后状态变成**未保存**，浏览器 localStorage 自动保存项目草稿。
2. 单击保存下载项目 JSON；保存后状态变成**已保存**，本地草稿被移除。
3. 打开项目时先完整校验格式和节点配置，成功后才原子替换当前画布。
4. 新建、打开或关闭页面前，如有未保存修改会提示确认。
5. 浏览器发现草稿时显示恢复按钮。恢复不会恢复源文件内容，运行前必须重新选择 CSV。

## 7. 错误处理

常见问题：

- `SOURCE_NOT_FOUND`：项目中的 CSV 输入没有对应文件绑定，重新选择文件。
- `SOURCE_PARSE_FAILED`：文件为空、CSV 行结构异常，或 XLSX 损坏。
- `COLUMN_NOT_FOUND`：配置中的列 ID 与上游 Schema 不一致，检查字段顺序和改名后的 ID。
- `JOIN_KEY_TYPE_MISMATCH`：左右 Join 键类型不同，先使用类型转换统一类型。
- `INPUT_DATA_NOT_AVAILABLE`：上游失败、未执行或图连接不完整。
- 配置面板错误：JSON 语法、必填字段、枚举值或文件名不符合 Schema；按错误路径修改后重新应用。

Worker 在节点失败后停止下游执行。警告不会必然终止运行，应在错误和日志页签确认数据是否符合预期。

## 8. 数据、性能和安全边界

- 文件在当前浏览器会话内存中处理，应用没有远程遥测或后端上传逻辑。
- 项目 JSON 和 localStorage 草稿不包含源数据，但源文件名和节点配置会保留在当前会话或下载项目中。
- 预览最多返回 1,000 行；总行数仍显示完整结果行数。
- 当前开发机实测 100,000 行、6 列、3,171,749 B CSV 为 467 ms，堆增加约 60.4 MiB。该数字不是其他设备的承诺。
- 自动性能门禁为 30 秒和额外 512 MiB JS 堆，用于发现严重回归。
- 取消只在异步文件读取和节点边界检查；同步 CSV 解析已经开始后不能中途抢占。
- 表达式只解释结构化 AST，不调用 `eval`、`new Function`、SQL 或系统命令。

## 9. 当前实现限制

- 工作区文件选择器当前只绑定 CSV。JSON 和 XLSX 的导入导出适配器及测试已经存在，但没有等价的可视化文件选择和导出控件。
- 顶部导出命令当前固定输出 CSV，没有按画布输出节点类型切换格式。
- 自动草稿依赖当前浏览器的 localStorage，不会跨浏览器或跨设备同步。
- 项目不提供服务器执行、后台队列、定时任务、多人协作或云端分享。

## 10. 验证命令

```bash
pnpm exec prettier --check .
pnpm lint
pnpm typecheck
pnpm test
pnpm test:e2e:all
pnpm test:performance
pnpm build
pnpm audit --prod
scripts/check-contract-sync.sh
```

Playwright 首次运行浏览器矩阵前需要：

```bash
pnpm exec playwright install
sudo pnpm exec playwright install-deps
```
