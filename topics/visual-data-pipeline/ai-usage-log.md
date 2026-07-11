# AI 使用记录

本文记录 AI 对可视化数据转换流水线项目的实际贡献，以及人工决策、修正和验证结果。

## 项目信息

- 项目：可视化数据转换流水线
- 代码目录：`/home/lucas/code/luke/project`
- 知识库：`/home/lucas/code/luke/study/topics/visual-data-pipeline`
- AI 工具：Codex
- 人工负责人：待填写

## 活动记录

### 2026-07-11：确定项目并建立开发知识库

- 目标：将“不依赖数据库的可视化数据转换流水线”拆解为可以由多个 Codex 终端并行开发的计划。
- AI 贡献：提出 MVP 边界、纯浏览器架构、共享契约、12 个工作日阶段安排、六终端所有权和任务依赖；建立产品、架构、契约、计划、测试和决策文档。
- 提示/任务摘要：用户选择可视化数据转换流水线，要求详细开发计划、任务拆分，并在当前目录的 `study/` 维护知识库。
- 产出：本目录中的项目知识库文档。
- 人工决策：用户确认项目方向，并指定 `study/` 为知识库位置；技术细节和任务边界仍需用户审阅。
- 验证：已确认 `study/` 为现有独立 Git 知识库，`project/` 为空的独立 Git 仓库；`git diff --check` 未发现空白错误；知识库入口列出的 8 个相对链接均对应已创建文件。
- 问题与修正：尚未发生实现错误；计划中的时间和性能数字均明确标记为目标或估计，不作为真实成效。
- 证据：`README.md`、`01-product-scope.md` 至 `06-testing-and-acceptance.md`、`decisions.md`。

### 2026-07-11：确立知识库提交规则

- 目标：确保知识库每次更新都有可追踪版本。
- AI 贡献：将用户要求转化为知识库维护规范，并准备首次提交。
- 提示/任务摘要：每次完善知识库后都需要 Git 提交。
- 产出：更新项目知识库入口中的维护规则。
- 人工决策：用户明确要求每次知识库更新后提交。
- 验证：提交前检查 Markdown 和 Git 状态；提交完成后在交付信息中报告实际提交哈希。
- 问题与修正：无。
- 证据：本文件及项目知识库 `README.md`。

### 2026-07-11：建立受限的知识库 Git Skill

- 目标：复用知识库的 Deploy Key 提交与推送流程，并限制使用目录和目标仓库。
- AI 贡献：查询 Codex 官方项目级 Skill 发现规则，设计 `push-luke-study` 的作用域校验、变更审查、提交和远程校验流程。
- 提示/任务摘要：把当前 Git 操作做成 Skill，并确保只有在 `/home/lucas/code/luke` 及其下级目录启动的 Codex 可以使用。
- 产出：`study/.agents/skills/push-luke-study` 及当前根目录、现有嵌套仓库的发现链接。
- 人工决策：用户指定目录作用域，并已授权 `luke-study` Deploy Key 写权限。
- 验证：系统 `quick_validate.py` 校验通过；`bash -n` 语法检查通过；从 `project/` 执行检查成功；从 `/tmp` 执行被作用域校验拒绝；根目录和 `project/` 的符号链接均解析到知识库中的唯一 Skill；敏感凭据模式扫描无匹配。提交和远程推送结果在交付信息中报告。
- 问题与修正：官方手册 helper 因响应缺少校验头失败，改用 OpenAI 官方文档确认 `.agents/skills` 的仓库扫描规则。
- 证据：Skill 文件、脚本测试结果、本次提交，以及 OpenAI 官方 `https://learn.chatgpt.com/docs/build-skills` 的项目级 Skill 位置说明。

### 2026-07-11：完善技术、开发规划和任务划分

- 目标：让知识库中的技术选型、阶段计划和多终端任务可以直接指导项目开发。
- AI 贡献：补充技术栈用途、选型理由、冻结状态、版本策略和依赖准入；为 12 天计划增加六个里程碑、质量门禁、合并顺序与风险降级；为六个终端增加任务包、启动规则、提示模板和 Definition of Done。
- 提示/任务摘要：在知识库写清项目使用的技术、开发规划和任务划分。
- 产出：更新 `02-architecture.md`、`04-development-plan.md` 和 `05-task-board.md`。
- 人工决策：用户要求这三类内容进入知识库；具体底层表格运算库、表达式库、XLSX 方案和目标浏览器仍需在原型阶段确认。
- 验证：`study-git.sh check` 和 `git diff --check` 通过；变更限定为 4 个预期文档，共新增 217 行；敏感凭据模式扫描无匹配；已确认技术栈包含待确认标记、开发计划包含 M0～M5、任务看板包含终端 0～5 和 Definition of Done。Git 提交及远程推送结果在交付信息中报告。
- 问题与修正：现有文档已有基本内容，因此选择原位补充而非新增重复文档，避免后续出现两个事实来源。
- 证据：上述三份文档、本次提交和各依赖官方文档链接。

### 2026-07-11：增加远程文件夹报告

- 目标：每次知识库提交推送后，明确告诉用户变更位于远程仓库的哪些文件夹。
- AI 贡献：更新 `push-luke-study` 的交付规则，并让推送脚本根据提交树自动计算、去重和排序远程文件夹。
- 提示/任务摘要：每次提交后报告远程文件夹，并把要求写入 Git 提交 Skill。
- 产出：更新 Skill、`study-git.sh`、知识库维护规则和 AI 使用记录。
- 人工决策：用户明确要求每次提交后都报告远程目录。
- 验证：系统 `quick_validate.py` 校验通过；`bash -n`、`study-git.sh check` 和 `git diff --check` 通过；敏感凭据模式扫描无匹配。实际远程文件夹输出和远程哈希一致性在本次推送后报告。
- 问题与修正：无。
- 证据：Skill、脚本、本次提交及推送输出。

### 2026-07-11：建立共享契约双副本

- 目标：形成可供多终端执行的完整共享契约，并确保知识库与代码仓库副本持续一致。
- AI 贡献：定义项目格式、节点配置、端口、数据批次、表达式 AST、数据源绑定、执行状态、Worker 消息、诊断、安全与契约测试；建立双副本校验脚本和工作区持久同步规则。
- 提示/任务摘要：在知识库和 `project` 各放一份契约，以后每次更新必须同时更新两边。
- 产出：`study/topics/visual-data-pipeline/03-contracts.md`、`project/docs/contracts.md`、`project/scripts/check-contract-sync.sh` 和工作区 `AGENTS.md`。
- 人工决策：用户明确要求契约双副本同步。
- 验证：两份契约均为 523 行，SHA-256 同为 `9e7e9162a4a0b59c0e701218cd78579090f0ab19a6da88dee2739b866a86fe54`；同步脚本和 `bash -n` 通过；两个仓库的 `git diff --check` 通过；敏感凭据模式扫描无匹配。Git 提交与远程推送结果在交付信息中报告。
- 问题与修正：原知识库契约只有概念级字段，扩展为版本化规范；公共边界中的日期改用 ISO 字符串，不跨 Worker 传递 JavaScript `Date`。
- 证据：两份契约、同步脚本、工作区规则和本次提交。

### 2026-07-11：完成 M0 工程基线

- 目标：完成 T0-01 至 T0-04，为多终端并行开发建立可重复的工程和契约基线。
- AI 贡献：初始化 pnpm workspace、React/Vite Web 壳、严格 TypeScript、ESLint、Prettier、Vitest 和 CI；实现 14 类节点配置、项目、数据、诊断与 Worker 的 Zod Schema；实现 Worker 最小处理器、虚构夹具和项目文档。
- 提示/任务摘要：按照任务计划持续执行，遇到需要新终端时再通知用户。
- 产出：`apps/web`、`packages/contracts`、`packages/test-fixtures`、根工具链、CI 和 README。
- 人工决策：没有采用 npm `latest` 的 TypeScript 7.0.2，因为 `typescript-eslint` peer range 小于 6.1；锁定 TypeScript 5.9.3。M0 Worker 只完成协议，不把未实现的节点执行描述为完成。
- 验证：`pnpm install --frozen-lockfile`、lint、typecheck、format check、build 和契约同步均通过；contracts 9 项测试和 web 6 项测试通过；Vite 开发服务器在 `http://localhost:5173/` 启动并通过 HTTP 页面和模块请求；敏感凭据模式扫描无匹配。
- 问题与修正：初次验证发现 ESLint 类型配置误作用于 JS 配置、Vite 的 test 配置类型来源错误、Vitest API 未显式导入、两个仓库使用不同 Prettier 配置导致契约漂移；分别通过限定 ESLint files、从 `vitest/config` 导入、显式导入测试 API、统一契约格式并将契约排除出普通格式化修正。收尾时曾根据短哈希写入未经验证的完整提交值，在知识库提交前通过 `git rev-parse HEAD` 发现并替换为真实值。
- 证据：项目提交 `5ea7e5157807e153a52ec8be26fc4e067e5f0cd7`、测试输出、构建产物统计和本次知识库提交。

### 2026-07-11：准备 Wave 1 并行工作区

- 目标：让五个功能终端从同一 M0 基线开始并行开发，避免共享目录写冲突。
- AI 贡献：创建 canvas、engine、file-adapters、node-config 和 qa-delivery 五个分支及 Git worktree；安装冻结依赖；建立项目级 Skill 发现链接。
- 提示/任务摘要：持续执行计划，在需要新开终端时通知用户。
- 产出：五个可直接打开的干净 worktree，均位于 `/home/lucas/code/luke` 下。
- 人工决策：用户授权持续执行，并要求在需要新终端时通知。
- 验证：五个 worktree 均位于项目提交 `5ea7e5157807e153a52ec8be26fc4e067e5f0cd7`，`pnpm install --frozen-lockfile` 成功，分支与任务所有权一致，Git 工作区干净，Skill 链接解析到知识库中的唯一版本。
- 问题与修正：首次批量状态检查的 JavaScript 工具编排字符串存在语法错误，未执行任何仓库操作；修正字符串后检查通过。
- 证据：`git worktree list`、各 worktree 的 Git 状态、依赖安装输出和任务看板。

### 2026-07-11：完成 Wave 1 并行骨架与主分支集成

- 目标：完成画布、执行引擎、文件适配器、节点面板和浏览器 QA 五个独立任务包，并将其集成为可运行的工作区骨架。
- AI 贡献：在五个 worktree 中分别实现 React Flow 画布与撤销重做、图校验与顺序调度器、CSV/JSON 解析和字段推断、配置校验与数据面板、Playwright/CI；按依赖顺序合并分支，并在主分支接通画布选中节点、配置编辑和运行数据面板。
- 提示/任务摘要：用户要求继续执行 Wave 1，仅在必须由用户操作时停止。
- 产出：画布提交 `cf21e21`、引擎提交 `d6c748a`、文件提交 `fb503b3`、节点面板提交 `91698a3`、QA 提交 `7ce9ad0`，以及主分支集成提交 `603a0ab906c5b1742bb697ef06d64c2089f61dda`。
- 人工决策：用户授权自主推进。实现中保持 M1 状态为进行中，因为现有 CSV 浏览器测试只验证文件上传读取，产品 UI 尚未串通 CSV 适配器、Worker 和真实预览。
- 验证：主分支 lint、typecheck、format check、build 和双副本契约同步通过；contracts 9 项、web 14 项、file-adapters 8 项、pipeline-engine 9 项，共 40 项单元/组件测试通过；Chromium 2 项 E2E 通过；在 1440×900 桌面和 Pixel 7 移动视口检查实际截图，画布非空白且未发现元素遮挡或文本溢出。
- 问题与修正：画布分支使用了不存在的 Lucide `FitScreen` 图标，由 typecheck 发现后改为 `Maximize2`；引擎分支修正了联合元组类型推断、重复输入优先触发导致的错误测试夹具和 mock 类型；节点分支修正 React effect 中同步 setState 的 lint 问题及只读夹具类型；QA 分支补充根 TypeScript 项目配置；合并文件适配器时仅 `pnpm-lock.yaml` 冲突，通过 pnpm 重新生成锁文件解决。集成测试发现 jsdom 缺少 `ResizeObserver`，在测试初始化中加入最小 mock；E2E 发现运行数据区域选择器与内部导航名称歧义，改用精确 region 角色。首次项目提交因仓库未配置作者身份失败，读取已有提交身份后仅在项目仓库本地配置并重试成功。
- 证据：上述六个项目提交、CI 配置、40 项测试输出、2 项 Playwright 输出、桌面与移动截图及契约同步哈希。

### 2026-07-11：建立工作起止进度报告 Skill

- 目标：让后续 Codex 在开始和结束项目工作时固定报告真实进度，并在需要用户操作时明确停止和说明阻塞。
- AI 贡献：创建项目级 `report-work-progress` Skill，定义开始报告、过程更新、结束报告、阻塞升级和知识库维护规则；建立根目录与 `project/` 的发现链接。
- 提示/任务摘要：用户要求继续开发前先写一个 Skill，规定开始工作和结束工作时输出当前进度。
- 产出：`study/.agents/skills/report-work-progress/SKILL.md` 和 `agents/openai.yaml`。
- 人工决策：用户明确要求把双阶段进度报告固化为 Skill。
- 验证：系统 `quick_validate.py` 通过；根目录与 `project/` 链接均解析到知识库中的唯一 Skill 目录。
- 问题与修正：首次初始化时中文短描述只有 20 个字符，不满足生成器要求的 25～64 字符，初始化器在生成 UI 元数据前停止；保留已创建的模板目录，完成正式内容后使用合规描述重新生成并验证。
- 证据：Skill 文件、验证输出、链接解析结果和本次知识库提交。

## 结果汇总

- 主要 AI 贡献：初版产品范围、架构、契约、并行计划、M0 工程基线、Wave 1 五模块实现、集成和测试策略。
- 主要人工修正与决策：待项目负责人审阅后补充。
- 已测量结果：Wave 1 主分支共 40 项单元/组件测试和 2 项 Chromium E2E 通过；生产构建成功；尚未进行数据处理性能测试。
- 限制和未解决风险：目标浏览器、标准性能设备和底层转换库尚未最终确认。
