---
title: net test bandwidth
date: 2025-10-26
private: true
---
# net test bandwidth
## ✅ 一、现成工具一键测试网络瓶颈

### 1. **`iperf3` / `iperf`**（推荐）
- **用途**：测量两节点之间的 **最大 TCP/UDP 带宽**。
- **是否饱和**：如果实测带宽接近你机器的物理带宽（如 1 Gbps ≈ 125 MB/s），则说明可能饱和。
- **用法示例**：
  ```bash
  # 服务端（节点A）
  iperf3 -s

  # 客户端（节点B，测试到A的带宽）
  iperf3 -c <nodeA-IP> -t 30 -i 1
  ```
- **判断**：若 节点间通信量 + 其他业务流量 > 实测可用带宽 → 可能是瓶颈。

---

### 2. **`ping` + `mtr`**
- **用途**：检测 **延迟（latency）和丢包（packet loss）**。
- **对延迟敏感**：即使带宽充足，高延迟或丢包也会导致心跳超时。
- **用法**：
  ```bash
  ping <ip>
  mtr <ip>  # 实时看路由和丢包
  ```
- **关注指标**：
  - 平均 RTT > 心跳间隔（如 100ms 心跳，RTT > 80ms 就危险）
  - 丢包率 > 0.1% 可能影响 稳定性

---

### 3. **`iftop` / `nethogs`**
- **用途**：实时监控 **节点当前网络流量**，看是否接近带宽上限。
- **用法**：
  ```bash
  sudo iftop -i eth0    # 按连接看实时带宽
  sudo nethogs eth0     # 按进程看带宽占用
  ```
- **判断**：如果 进程（或所在端口）持续占用高带宽，且总出口带宽打满 → 瓶颈。

---

## ✅ 二、用 Go 写一个简易网络瓶颈探测工具

如果你希望集成到测试流程中，可以用 Go 写一个轻量工具，**同时测带宽 + 延迟 + 丢包**。

### 🔧 工具功能设计：
1. **TCP 吞吐测试**（类似 iperf 简化版）
2. **ICMP Ping 延迟 & 丢包**
3. **输出结论**：是否可能为网络瓶颈

### 📦 示例代码（Go）

```go
package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"sync"
	"time"

	"golang.org/x/net/icmp"
	"golang.org/x/net/ipv4"
)

const (
	testDuration = 10 * time.Second
	packetSize   = 64 // bytes
)

func main() {
	peer := "192.168.1.10" 

	fmt.Println("🔍 开始网络瓶颈探测...")
	fmt.Printf("目标节点: %s\n\n", peer)

	// 1. 测延迟和丢包 (ICMP Ping)
	latency, loss := pingTest(peer, 10)
	fmt.Printf("📊 ICMP Ping 测试:\n")
	fmt.Printf("  平均延迟: %.2f ms\n", latency.Milliseconds())
	fmt.Printf("  丢包率: %.1f%%\n\n", loss*100)

	// 2. 测 TCP 吞吐 (简单版)
	bandwidthMBps := tcpThroughputTest(peer, "8080") 
	fmt.Printf("📈 TCP 吞吐测试 (10秒):\n")
	fmt.Printf("  估算带宽: %.2f MB/s (%.2f Mbps)\n\n", bandwidthMBps, bandwidthMBps*8)

	// 3. 简单判断
	if latency > 50*time.Millisecond || loss > 0.01 {
		fmt.Println("⚠️  警告: 高延迟或丢包可能导致 心跳超时！")
	}
	if bandwidthMBps > 100 { // 假设你的网络是千兆（125 MB/s），这里阈值可调
		fmt.Println("⚠️  警告: 带宽使用较高，可能接近上限！")
	}
}

// ICMP Ping 测试
func pingTest(addr string, count int) (avgLatency time.Duration, lossRate float64) {
	conn, err := icmp.ListenPacket("ip4:icmp", "0.0.0.0")
	if err != nil {
		log.Printf("Ping 失败: %v", err)
		return 0, 1.0
	}
	defer conn.Close()

	var total time.Duration
	sent, received := 0, 0

	for i := 0; i < count; i++ {
		sent++
		start := time.Now()

		wm := icmp.Message{
			Type: ipv4.ICMPTypeEcho, Code: 0,
			Body: &icmp.Echo{
				ID:   12345,
				Seq:  i,
				Data: make([]byte, packetSize),
			},
		}
		wb, _ := wm.Marshal(nil)
		if _, err := conn.WriteTo(wb, &net.IPAddr{IP: net.ParseIP(addr)}); err != nil {
			continue
		}

		conn.SetReadDeadline(time.Now().Add(1 * time.Second))
		rb := make([]byte, 1500)
		if n, _, err := conn.ReadFrom(rb); err == nil {
			rm, _, err := icmp.ParseMessage(1, rb[:n])
			if err == nil && rm.Type == ipv4.ICMPTypeEchoReply {
				received++
				total += time.Since(start)
			}
		}
		time.Sleep(100 * time.Millisecond)
	}

	if received == 0 {
		return 0, 1.0
	}
	return total / time.Duration(received), float64(sent-received) / float64(sent)
}

// TCP 吞吐测试（客户端）
func tcpThroughputTest(addr, port string) float64 {
	ctx, cancel := context.WithTimeout(context.Background(), testDuration)
	defer cancel()

	conn, err := net.Dial("tcp", addr+":"+port)
	if err != nil {
		log.Printf("无法连接 %s:%s", addr, port)
		return 0
	}
	defer conn.Close()

	// 发送大量数据
	data := make([]byte, 64*1024) // 64KB
	var sentBytes int64
	start := time.Now()

	var wg sync.WaitGroup
	wg.Add(1)
	go func() {
		defer wg.Done()
		for {
			select {
			case <-ctx.Done():
				return
			default:
				n, _ := conn.Write(data)
				sentBytes += int64(n)
			}
		}
	}()

	wg.Wait()
	elapsed := time.Since(start).Seconds()
	return float64(sentBytes) / elapsed / (1024 * 1024) // MB/s
}
```

> 💡 **注意**：
> - ICMP Ping 需要 root 权限（或 CAP_NET_RAW）
> - TCP 测试需要对方开启一个 echo 服务（或用 `nc -l 8080` 临时监听）
> - 更严谨的做法是用 `iperf3` 的 Go 封装，但上述代码适合快速集成

---

## 总结

| 方法 | 用途 | 是否一键 |
|------|------|--------|
| `iperf3` | 测带宽上限 | ✅ |
| `ping` / `mtr` | 测延迟/丢包 | ✅ |
| `iftop` | 实时流量监控 | ✅ |
| 自研 Go 工具 | 集成化诊断 | ✅（需编码） |