---
title: k8s monitor
date: 2024-07-08
private: true
---
# k8s monitor
Grafana 和 Prometheus 是两种不同的开源工具，它们在监控和可视化领域有不同的用途：

- Prometheus 主要用于数据的收集和存储，
是一个开源的系统监控和警报工具包，由 SoundCloud 开发。它提供了一种多维数据模型，时间序列数据以键值对的形式存储，使用 PromQL（Prometheus Query Language）进行数据查询。Prometheus 适合收集和存储时间序列数据，并提供了强大的数据查询和处理能力。

- Grafana 主要用于通用数据的可视化。特别是时间序列数据
开源的度量分析和可视化套件，常用于可视化时间序列数据。它支持多种数据源，包括 Prometheus、InfluxDB、Elasticsearch 等，并提供了丰富的图表类型和面板自定义选项。

- Kibana 是为Elasticsearch 官方设计的开源分析和可视化平台（不通用）