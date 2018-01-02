# comcast
Simulating shitty network connections so you can build better systems.
https://github.com/tylertreat/comcast

    $ comcast --device=eth0 --latency=250 --target-bw=1000 --default-bw=1000000 --packet-loss=10% --target-addr=8.8.8.8,10.0.0.0/24 --target-proto=tcp,udp,icmp --target-port=80,22,1000:2000 -dry-run
