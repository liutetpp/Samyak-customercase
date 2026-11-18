# KUNLUN Terraform 说明

本目录用于维护 KUNLUN GROUP LIMITED 全球互联网内容与互动业务平台迁移至 Azure 平台及 AI 平台能力建设项目的基础环境和核心资源部署代码。代码覆盖 Landing Zone 基础资源、网络规划、AKS、ACR、Azure Database for MySQL Flexible Server、对象存储、APIM、Functions、Azure OpenAI、Azure AI Search、Key Vault、Azure Monitor 与 Log Analytics。

## 项目信息

- 客户名称：KUNLUN GROUP LIMITED
- 实施主体：HONGKONG SAMYAK TECHNOLOGIES LIMITED
- 项目名称：KUNLUN GROUP LIMITED 全球互联网内容与互动业务平台迁移至 Azure 平台及 AI 平台能力建设
- 业务系统：全球互联网内容与互动业务平台
- 实施周期：2026-07-01 至 2026-08-31
- Azure 区域：Australia East

## 文件说明

| 文件 | 说明 |
| --- | --- |
| `provider.tf` | Terraform、AzureRM、Kubernetes provider 配置。 |
| `variables.tf` | 项目基础变量、资源命名、网络地址段、AKS 规格、数据库和 AI 服务参数。 |
| `main.tf` | 资源组、网络、AKS、数据库、存储、APIM、Functions、Azure OpenAI、Azure AI Search、Key Vault 和监控资源。 |
| `outputs.tf` | 输出资源组、网络规划、AKS、数据库、AI 服务和监控资源信息。 |
| `terraform.tfvars.example` | 执行前可复制为 `terraform.tfvars` 的变量示例。 |

## 核心资源

| 类型 | 资源命名 |
| --- | --- |
| AKS 集群 | `kunlun-aks-prod-aue-001` |
| System NodePool | `systemnp`，3 台 |
| User NodePool | `usernp`，8 台 |
| 节点规格 | `Standard_B8ms` |
| OS Disk | 256 GB |
| ACR | `kunlunacrpraue001` |
| MySQL Flexible Server | `kunlun-mysql-prod-aue-001` |
| Storage Account | `kunlunstprodaue001` |
| API Management | `kunlun-apim-prod-aue-001` |
| Azure Functions | `kunlun-functions-prod-aue-001` |
| Azure OpenAI | `kunlun-openai-prod-aue-001` |
| Azure AI Search | `kunlun-search-prod-aue-001` |
| Azure AI Foundry 项目 | `kunlun-aifoundry-prod-aue-001` |
| Key Vault | `kunlun-kv-prod-aue-001` |
| Log Analytics | `kunlun-law-prod-aue-001` |

## 网络规划

| 区域 | VNet | 子网 | 地址空间 | 用途 |
| --- | --- | --- | --- | --- |
| Australia East | AKS-VNet | service-subnet | `192.168.6.0/22` | Kubernetes Service CIDR，用于 AKS 集群内部 Service 网络。 |
| Australia East | AKS-VNet | pod-subnet | `172.24.0.0/20` | AKS Pod 地址段，用于业务服务、AI 编排服务、Agent 后端服务和 DevOps 相关 Pod。 |
| Australia East | AKS-VNet | node-subnet | `10.8.16.0/22` | AKS 节点子网，用于生产和开发环境的 system nodepool 与 user nodepool。 |
| Australia East | AKS-VNet | internal-lb-subnet | `10.8.35.0/24` | 内部负载均衡子网，用于 AKS 内部服务暴露、内部入口和后端服务间调用。 |
| Australia East | DB-VNet | mysql-subnet | `10.8.28.0/24` | 数据服务子网，用于 Azure Database for MySQL Flexible Server 私有访问。 |
| Australia East | Hub-VNet | nfs-subnet | `10.8.45.32/28` | Hub 网络共享服务/迁移期访问子网，用于共享网络能力、运维接入或后续扩展。 |

## AKS 命名空间

| Namespace | 用途 |
| --- | --- |
| `kunlun-system` | 平台系统组件 |
| `kunlun-ingress` | 入口网关和 Ingress 组件 |
| `kunlun-observability` | 监控、日志和可观测性组件 |
| `kunlun-prod` | 生产业务服务 |
| `kunlun-data` | 数据访问相关组件 |
| `kunlun-ai` | AI 编排、Agent 工具调用和检索增强服务 |
| `kunlun-devops` | DevOps 辅助任务和部署组件 |

## 执行方式

使用 Azure CLI 登录并选择目标订阅：

```powershell
az login
az account set --subscription "<subscription-id>"
```

复制变量示例并调整全局唯一资源名和数据库密码：

```powershell
Copy-Item .\terraform.tfvars.example .\terraform.tfvars
notepad .\terraform.tfvars
```

初始化并预览部署计划：

```powershell
terraform init
terraform validate
terraform plan -out tfplan
```

确认计划后执行部署：

```powershell
terraform apply tfplan
```

## 注意事项

- `terraform.tfstate`、`.terraform`、`.terraform.lock.hcl` 是否提交由仓库策略决定；正式交付代码不应提交包含敏感信息的 state 文件。
- `terraform.tfvars` 可能包含密码、订阅信息或全局唯一资源名，默认不建议提交。
- Azure OpenAI、Azure AI Search、APIM、Functions 和 AKS 的业务代码部署由 DevOps 流水线完成；本目录主要负责基础环境和核心托管资源。
- Azure AI Foundry 项目和 Agent Service 的配置通常需要结合 Azure AI Foundry 门户、模型部署、Agent 工具定义和权限治理完成；Terraform 代码保留项目级命名和资源组标签，便于与实施文档、As-Built 记录和运维监控对齐。
