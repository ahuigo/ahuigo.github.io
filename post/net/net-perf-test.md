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
    -t 30  # 测试30秒
    -i 1   # 每秒输出一次结果
  ```
- **判断**：若 节点间通信量 + 其他业务流量 > 实测可用带宽 → 可能是瓶颈。

### 1.2 iftop 监控实时流量
sudo iftop -i eth0

### 2. **`ping` + `mtr`**
- **用途**：检测 **延迟（latency）和丢包（packet loss）**。
- **对延迟敏感**：即使带宽充足，高延迟或丢包也会导致心跳超时。
- **用法**：
  ```bash
  ping <ip>
  mtr <ip>  # 实时看路由和丢包
  ethtool -S eth0 | grep -E 'tx_packets|drop'  # 查看网卡错误
  ```
- **关注指标**：
  - 平均 RTT > 心跳间隔（如 100ms 心跳，RTT > 80ms 就危险）
  - 丢包率 > 0.1% 可能影响 稳定性

### ss 分析 tcp 连接状态
    # ss -ti src 10.27.11.112:30100
    State   Recv-Q    Send-Q       Local Address:Port        Peer Address:Port    Process                                                                       
    ESTAB   0         0             10.27.11.112:30100       10.27.11.113:49260   
        cubic wscale:7,7  
            窗口缩放因子 (Window Scale)，双方都使用了 2^7=128 的缩放因子，用于支持更大的 TCP 窗口。
        rto:204 
            重传超时 (Retransmission Timeout)。如果发送一个包后 204ms 内未收到 ACK，则会重传。
        rtt:0.047/0.007 
            往返时间 (Round-Trip Time)。第一个值是平滑 RTT，第二个是 RTT 的变化方差
        rcv_rtt:69617.1
            接收端测量的 RTT，为 69617.1 微秒 (约 69.6ms)。
        minrtt:0.031
        rcv_space:65330 
            接收缓冲区的剩余空间。单位是字节 (Bytes)，用于 TCP 流量控制。
        rcv_ssthresh:394252 
            接收方感知的慢启动阈值。单位是字节 (Bytes)，用于 TCP 拥塞控制。
                当对端的 cwnd*1448 小于 ssthresh 时，它会处于慢启动阶段，cwnd 会指数级快速增长。
                当对端的 cwnd*1448 超过 ssthresh 时，它会进入拥塞避免阶段，cwnd 会线性缓慢增长。
        ato:40 
            延迟时间 (Acknowledgment Timeout)，回ACK 的时间加一个40ms延迟，等seq+ack 一起发出去
        pmtu:1500 
            路径最大传输单元 (MTU)，当前允许的最大 IP 包大小为 1500 字节。
        mss:1448
            最大TCP报文段长度 (Maximum Segment Size)，每个 TCP 段的最大数据量为 1448 字节。
            mss=MTU−(IP Header Size)−(TCP Header Size) =1500−20−32=1448 字节
        rcvmss:536 
            接收端的最大报文段长度为 536 字节。
        advmss:1448 
            三次握手告诉接收方的最大TCP报文段长度为 1448 字节。
        cwnd:10  
            拥塞窗口 (Congestion Window)。当前拥塞窗口大小是 10 个 MSS。
            发送方被允许一次性向网络中发送 10 辆满载货物（10 * 1448 字节）的卡车
        bytes_sent:3371712 
            已经发送的字节数为 3,371,712 字节。
        bytes_acked:3371712
            已经被对方确认收到的字节数为 3,371,712 字节。
        bytes_received:4881958 
            已经接收的字节数为 4,881,958 字节。
        segs_out:35123
            已经发送的报文段数为 35,123 个。
        segs_in:70246 
            已经接收的报文段数为 70,246 个。
        data_segs_out:35122 
            已经发送的数据报文段数为 35,122 个。
        data_segs_in:35122 
            已经接收的数据报文段数为 35,122 个。
        lastsnd:20 
            最后发送时间距离现在 20ms。
        lastrcv:28 
            最后接收时间距离现在 28ms。
        lastack:20 
            最后确认时间距离现在 20ms。

        pacing_rate 4.93Gbps 
            核认为网络能承受的“速度极限”
        send 2.46Gbps 
            理论发送速率为 2.46 Gbps。
            send_rate≈ cwnd×MSS/RTT 
        delivery_rate 374Mbps
            在过去一段时间内，数据被实际成功交付并确认的速率
        delivered:35123 
            已成功交付的TCP总报文段数 (Packets/Segments)
        app_limited 
            此标志出现(同时busy不增长)，说明 delivery_rate (374Mbps) 远小于 pacing_rate (4.93Gbps) 的根本原因是应用程序发得慢。
        busy:1592ms
            应用在过去一段时间内，处于向 socket 写入数据（忙碌）状态的累计总时长。
            如果它持续增长，说明tcp发送缓存区满了，应用写不进去数据，可能是网络瓶颈

pacing_rate (步调速率)+send rate (发送速率) 怎么算出来的：
- pacing_rate: 由估算的瓶颈带宽 (BtlBw) 决定, 通过拥塞控制算法 BBR (Bottleneck Bandwidth and Round-trip propagation time) 会周期性地、短暂地提高发送速率试探网络的带宽极限：
    1. 如果提速后，delivery_rate 也跟着上升了，说明网络还有余量，BBR 就会更新它对 BtlBw 的估计。 
    2. 如果提速后，delivery_rate 不再上升，反而 rtt 开始增加了（说明数据开始在路由器里排队了）
- send rate: 当前允许的最大发送速率
    - 当前 cwnd / RTT 算出来的. 可能波动较大

ss 参数：

    -t 显示 TCP 连接
    -i 显示详细信息
    src ip:port 过滤源地址
    dst ip:port 过滤目的地址

从 ss -ti 输出看:

    State	ESTAB	连接处于 ESTABLISHED 状态，即已建立的稳定连接。
    Send-Q: 0 - 发送队列为空,说明 follower 没有积压待发送的数据
    Recv-Q: 0 - 接收队列为空
    rtt:0.047/0.007 和 rtt:0.048/0.008 - RTT 非常低(约 47-48μs)
    busy:1592ms 和 busy:3400ms - 连接忙碌时间很短
    app_limited  表示该连接的发送速率受限于应用程序（application）而不是网络拥塞

### 3. **`iftop` / `nethogs`**
- **用途**：实时监控 **节点当前网络流量**，看是否接近带宽上限。
- **用法**：
  ```bash
  sudo iftop -i eth0    # 按连接看实时带宽
  sudo nethogs eth0     # 按进程看带宽占用
  ```
- **判断**：如果 进程（或所在端口）持续占用高带宽，且总出口带宽打满 → 瓶颈。

### perf 动态分析进程cpu瓶颈
perf top -g -p $pid
    -g 开启**调用图（call graph）**模式


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

## 总结

| 方法 | 用途 |
|------|------|
| `iperf3` | 测带宽上限 |
| `ping` / `mtr` | 测延迟/丢包 |
| `iftop` | 实时流量监控 |
| 自研 Go 工具 | 集成化诊断 | 