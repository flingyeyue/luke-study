# Luke Study：可视化数据转换流水线教学手册

这是 Luke Study 知识库的主入口，当前完整记录“可视化数据转换流水线”项目的需求、架构、契约、开发、测试、AI 使用证据和演示教学。

## 项目知识库

- [专题首页](topics/visual-data-pipeline/README.md)
- [产品范围](topics/visual-data-pipeline/01-product-scope.md)
- [技术架构](topics/visual-data-pipeline/02-architecture.md)
- [核心契约](topics/visual-data-pipeline/03-contracts.md)
- [开发计划](topics/visual-data-pipeline/04-development-plan.md)
- [任务看板](topics/visual-data-pipeline/05-task-board.md)
- [测试与验收](topics/visual-data-pipeline/06-testing-and-acceptance.md)
- [使用与功能指南](topics/visual-data-pipeline/07-user-guide.md)
- [架构决策](topics/visual-data-pipeline/decisions.md)
- [AI 使用记录](topics/visual-data-pipeline/ai-usage-log.md)

## 1. 手册目标

本手册用于远程演示和第一次上手。完成后，参与者应能：

- 从公网或本地地址打开应用。
- 导入 CSV 并理解浏览器本地处理的边界。
- 在画布上创建、配置和执行单输入流水线。
- 使用两个 CSV 创建 inner Join。
- 查看数据、字段、日志和错误。
- 导出结果、保存项目并恢复草稿。
- 说明当前实现能力、性能证据和限制。

完整功能和配置字段参考见[使用与功能指南](topics/visual-data-pipeline/07-user-guide.md)。本手册强调操作顺序和演示话术。

## 2. 演示前准备

### 2.1 访问地址

当前远程演示地址：

```text
http://devdemo.s7.tunnelfrp.com
```

该地址通过 Sunny-Ngrok 转发到远程机器的 `127.0.0.1:5180`。它是公开 HTTP 地址，不要导入真实敏感数据。

如果公网地址不可用，维护者在远程机器执行：

```bash
cd /home/lucas/code/luke/project
pnpm build
__VITE_ADDITIONAL_SERVER_ALLOWED_HOSTS=<公网域名> \
  pnpm --dir apps/web exec vite preview \
  --host 0.0.0.0 --port 5180 --strictPort
```

然后使用 Sunny-Ngrok 控制台提供的 Linux 命令启动隧道。隧道 ID 不应写入知识库、截图或公开演示材料。

### 2.2 浏览器

推荐桌面 Chromium、Firefox 或 Safari/WebKit。首次通过 3 Mbps 隧道打开生产页面约需 8～10 秒。若超过 20 秒仍为空白：

1. 使用 `Ctrl+Shift+R` 强制刷新。
2. 打开无痕窗口重试。
3. 确认标题为“数据流水线”。
4. 让维护者检查生产预览服务和隧道进程是否都在线。

不要用 Vite 开发服务器做公网演示。开发模式会通过隧道请求大量源码模块和 HMR WebSocket，表现为页面持续转圈；生产构建正常只加载 HTML、一个 JS 和一个 CSS。

### 2.3 准备订单 CSV

在自己的电脑新建 `orders-demo.csv`，保存以下内容：

```csv
order_id,order_date,region,status,amount,tax_rate
ORD-1001,2026-01-03,north,completed,120.50,0.08
ORD-1002,2026-01-04,south,cancelled,88.00,0.08
ORD-1003,2026-01-05,east,completed,240.25,0.10
ORD-1004,2026-01-07,west,pending,59.90,0.08
ORD-1005,2026-02-01,north,completed,410.00,0.10
ORD-1006,2026-02-02,south,completed,175.75,0.08
ORD-1007,invalid-date,east,completed,not-a-number,0.10
ORD-1008,2026-02-09,west,cancelled,92.40,0.08
ORD-1009,2026-03-11,north,completed,,0.10
ORD-1010,2026-03-14,south,completed,315.20,0.08
```

也可以从项目仓库使用固定夹具：

```text
project/packages/test-fixtures/data/orders-small.csv
```

注意：浏览器文件选择器读取的是演示者电脑上的文件。即使应用部署在远程机器，也不能在选择器里直接浏览远程仓库路径。

### 2.4 准备地区 CSV

新建 `regions-demo.csv`：

```csv
region,owner
north,Morgan Lee
south,Taylor Kim
east,Jordan Singh
west,Casey Chen
```

### 2.5 演示前检查表

- 公网首页可打开，标题和节点库可见。
- 浏览器缩放为 100%。
- 两份 CSV 已保存在本地。
- 页面是空白新项目，状态显示“已保存”。
- 不使用真实公司数据、个人信息或凭据。
- 预留一个无痕窗口，用于演示异常恢复。

## 3. 十分钟快速演示

### 第一步：说明架构和隐私，1 分钟

展示空白工作区并讲解：

> 这是一个无数据库、无后端的数据转换工具。文件由浏览器读取，计算在 Web Worker 中执行，项目文件只保存流水线定义，不保存原始数据。

指出五个区域：顶部命令栏、左侧节点库、中间画布、右侧配置、底部运行面板。

预期状态：运行和导出按钮不可用，底部显示 0 行。

### 第二步：导入订单 CSV，1 分钟

1. 单击顶部**选择 CSV**。
2. 选择 `orders-demo.csv`。
3. 观察画布自动创建 CSV 输入节点。
4. 观察状态显示文件名和字节数，项目变为“未保存”。

讲解：文件只绑定到当前浏览器会话；保存项目后再次打开仍需重新选择源文件。

### 第三步：创建单输入流水线，2 分钟

1. 单击节点库的**筛选**。
2. 新节点自动连接到 CSV 输入并成为当前选中节点。
3. 默认筛选配置是布尔字面量 true，暂时保留全部数据。
4. 单击**CSV 输出**，系统自动连接当前末端。

可展示画布工具栏的缩放和适配视图。说明无效端口、重复输入和环会被画布拒绝。

### 第四步：运行和查看结果，2 分钟

1. 单击顶部**运行**。
2. 等待状态从排队/解析变为“完成”或“完成，有警告”。
3. 在**数据**页签确认 10 行和首末订单。
4. 切换到**字段**，确认 `amount` 推断为 number 或因混合值推断为 string，并解释类型推断基于实际数据。
5. 切换到**日志**，展示 `run-started`、`node-result`、`run-completed` 等事件。
6. 切换到**错误**，正常流程应显示 0。

讲解：Worker 保存每个成功节点结果，主线程只请求最多 1,000 行预览，避免一次渲染全量数据。

### 第五步：导出和保存，2 分钟

1. 单击顶部**导出**，确认下载 `pipeline-output.csv`。
2. 打开下载文件，确认包含 `ORD-1010`。
3. 单击保存项目图标，下载项目 JSON。
4. 用文本编辑器打开项目 JSON，展示节点、边、位置和配置。
5. 搜索 `ORD-1001`，应找不到原始订单行。

### 第六步：总结，2 分钟

展示并说明：

- 具备选择/重命名、类型转换、筛选、计算、排序、去重、分组和 Join 引擎。
- 100,000 行、6 列基准在当前开发机干净环境实测 467 ms。
- Chromium、Firefox、WebKit 和移动 Chromium 共 12 项 E2E 已通过。
- 当前 UI 文件选择器只支持 CSV，配置仍使用校验 JSON，导出按钮当前固定输出 CSV。

## 4. 二十五分钟完整教学

## 4.1 熟悉工作区，3 分钟

### 项目命令

- 文件加号：新建项目。
- 文件夹：打开项目 JSON。
- 软盘：保存项目 JSON。
- 回转箭头：恢复浏览器本地草稿，仅在有草稿时出现。
- “已保存/未保存”：当前脏状态。

### 画布命令

- 左箭头：撤销。
- 右箭头：重做。
- 放大镜减号/加号：缩放。
- 对角箭头：适配全部节点。
- `Delete` 或 `Backspace`：删除选中节点或边。

### 数据面板

- 数据：预览和行数。
- 字段：名称、类型和可空性。
- 日志：Worker 事件。
- 错误：错误代码和消息。

## 4.2 理解列 ID，3 分钟

节点配置引用稳定列 ID，而不是显示名称。生成规则是：字段名小写、非字母数字变为连字符，再附加从 1 开始的顺序。

订单示例：

| 顺序 | 字段       | 列 ID        |
| ---: | ---------- | ------------ |
|    1 | order_id   | order-id-1   |
|    2 | order_date | order-date-2 |
|    3 | region     | region-3     |
|    4 | status     | status-4     |
|    5 | amount     | amount-5     |
|    6 | tax_rate   | tax-rate-6   |

地区示例中的 `region` 是第一列，所以 ID 是 `region-1`。这就是 Join 左右键名称相同但 ID 不同的原因。

## 4.3 配置筛选，4 分钟

1. 导入订单 CSV。
2. 添加筛选节点。
3. 保持右侧**可视化**模式，把“表达式类型”设为“双目运算”，运算符设为“不等于”。
4. 把左值类型设为“字段”，字段 ID 填 `status-4`；右值保持“固定值 / 文本”，值填 `cancelled`。
5. 可切换到 **JSON** 查看同步后的完整配置：

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

6. 切回可视化模式，单击**应用**，确认“配置已应用”。
7. 添加 CSV 输出并运行。
8. 预期剩余 8 行，`ORD-1002` 和 `ORD-1008` 不再出现。

讲解：表达式是受限 AST，不执行 JavaScript、SQL 或系统命令。

### 故意制造配置错误

把 `operator` 改为 `equals` 并应用。预期配置面板显示枚举校验错误，旧的有效配置不会被覆盖。改回 `neq` 后重新应用。

## 4.4 配置计算字段，4 分钟

在筛选后添加**计算字段**：

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

订单夹具包含 `not-a-number`，`amount` 可能被推断为 string，计算会产生类型诊断。利用该结果说明：

1. 真实流水线应先增加类型转换。
2. 类型转换可选择 `fail`、`null` 或 `keep-original`。
3. 错误会定位到节点和字段，不会执行错误下游。

类型转换示例：

```json
{
  "rules": [
    { "columnId": "amount-5", "targetType": "number", "onError": "null" }
  ]
}
```

把类型转换放在计算字段之前，再运行。非法金额变为 null 并产生警告，其余行可以计算。

## 4.5 创建双输入 Join，6 分钟

为避免已有单输入分支影响自动连接，可先新建项目，然后执行：

1. 选择 `orders-demo.csv`，产生第一个 CSV 输入。
2. 从节点库添加第二个**CSV 输入**。
3. 再次单击**选择 CSV**，选择 `regions-demo.csv`。文件会绑定到尚未绑定的输入。
4. 添加**关联**节点。系统尝试把最近两个未连接末端接到 left/right。
5. 检查 Join 节点左侧是否有两条边，端口标签分别为 left 和 right。
6. 应用配置：

```json
{
  "joinType": "inner",
  "leftKeys": ["region-3"],
  "rightKeys": ["region-1"],
  "rightColumnPrefix": "region."
}
```

7. 添加 CSV 输出并运行。
8. 在字段页签确认出现 `owner`。
9. 在数据页签确认 10 行，north 对应 Morgan Lee，south 对应 Taylor Kim。

讲解：

- inner 只保留匹配行；left 保留左侧未匹配行。
- null 键不匹配。
- 右侧重复键会展开为多行。
- 左右同名字段会给右字段增加前缀。
- left/right 角色由端口决定，不依赖边创建顺序。

## 4.6 项目恢复，3 分钟

1. 修改任一节点配置，确认状态变为“未保存”。
2. 单击新建，确认出现未保存提示，选择取消。
3. 刷新页面，浏览器可能显示离开确认。
4. 重新进入后单击恢复草稿。
5. 确认节点和配置恢复，但运行前仍需重新选择 CSV。
6. 保存项目后，草稿按钮消失，状态变为“已保存”。

讲解：localStorage 和项目 JSON 都不保存原始行或 `File` 对象。

## 5. 其他节点练习

### 选择和重命名

```json
{
  "columns": [
    { "sourceColumnId": "order-id-1", "outputName": "订单号" },
    { "sourceColumnId": "region-3", "outputName": "地区" },
    { "sourceColumnId": "amount-5", "outputName": "金额" }
  ]
}
```

预期只保留三列，并按配置顺序输出。

### 排序

```json
{
  "rules": [
    { "columnId": "region-3", "direction": "asc", "nulls": "last" },
    { "columnId": "amount-5", "direction": "desc", "nulls": "last" }
  ]
}
```

预期先按地区升序，再在地区内按金额降序。空值始终位于最后。

### 去重

```json
{
  "columnIds": ["order-id-1"],
  "keep": "first"
}
```

预期保留每个订单号首次出现的行。

### 分组统计

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

金额列必须先转换为 number。sum 和 avg 忽略 null；无列 count 统计行数。

## 6. 常见问题处理

### 页面一直转圈或资源持续加载

原因通常是公网隧道后运行了 Vite 开发服务器。切换为 `pnpm build` 后的 `vite preview`，并确认公网加载的资源路径是 `/assets/index-*.js`，而不是 `/src/main.tsx`。

### Bad Gateway 或 Tunnel Unavailable

分别检查：

1. `127.0.0.1:5180` 是否返回 200。
2. 生产预览进程是否仍在运行。
3. Sunny 客户端是否显示“隧道启动成功”并持续发送 Ping。
4. 控制台隧道本地端口是否为 5180。
5. Vite 的 `__VITE_ADDITIONAL_SERVER_ALLOWED_HOSTS` 是否为实际公网域名。

### 页面提示 Host 不允许

不要配置 `allowedHosts: true`。重启生产预览，只允许实际域名：

```bash
__VITE_ADDITIONAL_SERVER_ALLOWED_HOSTS=devdemo.s7.tunnelfrp.com \
  pnpm --dir apps/web exec vite preview \
  --host 0.0.0.0 --port 5180 --strictPort
```

### 运行按钮不可用

尚未选择 CSV。先选择至少一份文件。

### SOURCE_NOT_FOUND

项目图有 CSV 输入，但当前会话没有对应文件绑定。重新选择文件。打开项目或恢复草稿后必须重新绑定源文件。

### COLUMN_NOT_FOUND

配置中的列 ID 不存在。检查字段顺序、上游选择/重命名结果和 ID 生成规则。

### JOIN_KEY_TYPE_MISMATCH

左右键类型不同。在 Join 前增加类型转换，使两侧类型一致。

### 导出只有 1,000 行

当前顶部导出按钮导出已返回主线程的预览 batch，预览上限为 1,000 行。这是当前限制，不应在演示中声称可以从按钮导出完整大结果。

## 7. 演示者话术建议

### 开场

> 我们选择了一个不依赖数据库的可视化数据流水线。它重点展示 AI 如何参与需求拆分、共享契约、并行开发、测试、性能测量、安全修正和交付，而不是只生成一个页面。

### 讲架构

> React 和 React Flow 负责编辑体验；Zod 契约约束项目文件和 Worker 消息；计算在 Web Worker 与纯函数引擎中执行；文件适配器负责 CSV、JSON、XLSX 和项目格式。当前工作区把 CSV 主链路完整接通。

### 讲安全

> 用户表达式是结构化 AST，不执行任意代码。CSV 和 XLSX 导出防护电子表格公式注入。项目文件和草稿不保存原始数据，生产依赖审计没有已知漏洞。

### 讲质量

> 干净远程克隆完成冻结安装后，107 项单元和组件测试、12 项跨浏览器 E2E、1 项 100,000 行性能 E2E、构建、契约同步和依赖审计全部通过。

### 讲 AI 使用

> AI 的贡献、错误和修正都记录在知识库。例如日期解析最初会接受不存在的日期、移动布局最初隐藏核心控件、依赖 override 最初放错 pnpm 11 配置位置；这些问题由测试和审查发现并保留证据。

### 收尾

> 当前版本完成了可演示 MVP，同时明确保留 JSON/XLSX 文件控件、完整大结果导出和同步解析取消等限制，没有把底层库能力包装成已经交付的用户功能。

## 8. 演示验收表

| 项目                       | 预期结果                        |
| -------------------------- | ------------------------------- |
| 公网页面首次打开           | 约 8～10 秒内显示完整工作区     |
| 生产公网请求               | HTML、一个主 JS、一个 CSS       |
| CSV 输入                   | 自动创建输入节点并显示文件状态  |
| 单输入执行                 | 10 行夹具可预览和导出           |
| 取消订单筛选               | 结果为 8 行                     |
| 双输入 Join                | 10 行且出现 owner 字段          |
| 配置错误                   | 显示字段路径且不覆盖旧有效配置  |
| 项目保存                   | JSON 不包含 ORD-1001 等源数据   |
| 草稿恢复                   | 恢复图和配置，源文件需重新选择  |
| 跨浏览器证据               | 4 个浏览器/视口项目共 16 项 E2E |
| 100,000 行干净环境性能证据 | 467 ms，堆增加约 60.4 MiB       |
| 生产依赖审计               | 0 个已知漏洞                    |

## 9. 教学结束后的清理

1. 关闭演示页面和下载的临时结果。
2. 删除本地练习 CSV 和项目文件，尤其是后续使用了自有数据时。
3. 不再需要公网访问时停止 Sunny-Ngrok 客户端。
4. 停止远程 `vite preview` 服务。
5. 确认项目和知识库 Git 工作树没有演示产生的文件。

本手册中的 Sunny 域名和性能数字属于当前演示环境。更换隧道、域名、端口或硬件后，应重新验证并更新，而不是沿用旧结果。
