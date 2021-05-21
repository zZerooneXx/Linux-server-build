#!/bin/bash
#
# Author: https://github.com/zZerooneXx

which bc
if [ $? -ne 0 ]; then
    echo "You need to install bc"
fi

mem_bytes=$(awk '/MemTotal:/ { printf "%0.f",$2 * 1024}' /proc/meminfo)
shmmax=$(echo "$mem_bytes * 0.90" | bc | cut -f 1 -d '.')
shmall=$(expr $mem_bytes / $(getconf PAGE_SIZE))
max_orphan=$(echo "$mem_bytes * 0.10 / 65536" | bc | cut -f 1 -d '.')
file_max=$(echo "$mem_bytes / 4194304 * 256" | bc | cut -f 1 -d '.')
max_tw=$(($file_max*2))
min_free=$(echo "($mem_bytes / 1024) * 0.01" | bc | cut -f 1 -d '.')

>/etc/sysctl.conf cat << EOF 

kernel.sysrq = 0
kernel.core_uses_pid = 1
kernel.randomize_va_space = 2
kernel.kptr_restrict = 1
kernel.exec-shield = 1
kernel.maps_protect = 1
kernel.msgmnb = 65535
kernel.msgmax = 65535
kernel.pid_max = 65535
kernel.shmmax = $shmmax
kernel.shmall = $shmall
kernel.sched_migration_cost_ns = 5000000
kernel.sched_autogroup_enabled = 0

fs.suid_dumpable = 0
fs.file-max = $file_max

vm.dirty_ratio = 30
vm.swappiness = 1
vm.dirty_background_ratio = 5
vm.dirty_background_bytes = 67108864
vm.dirty_bytes = 134217728
vm.mmap_min_addr = 4096
vm.min_free_kbytes = $min_free
vm.overcommit_ratio = 50
vm.overcommit_memory = 0
vm.nr_hugepages = 1024
vm.vfs_cache_pressure = 50
vm.zone_reclaim_mode = 0
net.ipv4.tcp_syncookies = 0
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.tcp_fin_timeout = 7
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_synack_retries = 3
net.ipv4.tcp_syn_retries = 3
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_rfc1337 = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_congestion_control = htcp
net.ipv4.tcp_notsent_lowat = 16384
net.ipv4.tcp_orphan_retries = 0
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_moderate_rcvbuf = 1
net.ipv4.tcp_ecn = 0
net.ipv4.tcp_reordering = 3
net.ipv4.tcp_retries1 = 3
net.ipv4.tcp_retries2 = 15
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_mem = 8388608 12582912 16777216
net.ipv4.tcp_rmem = 4096 87380 8388608
net.ipv4.tcp_wmem = 4096 65536 8388608
net.ipv4.udp_mem = 8388608 12582912 16777216
net.ipv4.udp_rmem_min = 16384
net.ipv4.udp_wmem_min = 16384
net.ipv4.tcp_max_tw_buckets = $max_tw
net.ipv4.tcp_max_orphans = $max_orphan

net.ipv4.inet_peer_gc_mintime = 5

net.ipv4.netfilter.ip_conntrack_buckets = 65536
net.ipv4.netfilter.ip_conntrack_generic_timeout = 60
net.ipv4.netfilter.ip_conntrack_icmp_timeout = 10
net.ipv4.netfilter.ip_conntrack_tcp_timeout_close = 10
net.ipv4.netfilter.ip_conntrack_tcp_timeout_close_wait = 20
net.ipv4.netfilter.ip_conntrack_tcp_timeout_established = 900
net.ipv4.netfilter.ip_conntrack_tcp_timeout_fin_wait = 30
net.ipv4.netfilter.ip_conntrack_tcp_timeout_last_ack = 30
net.ipv4.netfilter.ip_conntrack_tcp_timeout_syn_recv = 30
net.ipv4.netfilter.ip_conntrack_tcp_timeout_syn_sent = 15
net.ipv4.netfilter.ip_conntrack_tcp_timeout_syn_sent2 = 15
net.ipv4.netfilter.ip_conntrack_tcp_timeout_time_wait = 30
net.ipv4.netfilter.ip_conntrack_udp_timeout = 30
net.ipv4.netfilter.ip_conntrack_udp_timeout_stream = 45

net.netfilter.nf_conntrack_max = 1048576
net.nf_conntrack_max = 1048576

net.ipv4.ip_forward = 0
net.ipv4.ip_local_port_range = 1024 65535

net.ipv4.conf.all.forwarding = 0
net.ipv4.conf.default.forwarding = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.log_martians = 0
net.ipv4.conf.default.log_martians = 0
net.ipv4.conf.all.bootp_relay = 0
net.ipv4.conf.all.proxy_arp = 0
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.force_igmp_version = 2

net.ipv4.icmp_echo_ignore_all = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

net.ipv4.neigh.default.gc_thresh1 = 32
net.ipv4.neigh.default.gc_thresh2 = 1024
net.ipv4.neigh.default.gc_thresh3 = 2048
net.ipv4.neigh.default.gc_interval = 30
net.ipv4.neigh.default.proxy_qlen = 96
net.ipv4.neigh.default.unres_qlen = 6

net.ipv4.ipfrag_low_thresh = 196608
net.ipv4.ipfrag_high_thresh = 262144

net.ipv4.tcp_fack = 1
net.ipv4.tcp_dsack = 1
net.ipv4.route.flush = 1

net.core.rmem_default = 16777216
net.core.rmem_max = 16777216
net.core.wmem_default = 16777216
net.core.wmem_max = 16777216
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 16384
net.core.dev_weight = 64
net.core.optmem_max = 204800
net.core.default_qdisc = fq
net.core.netdev_budget = 50000

net.unix.max_dgram_qlen = 50

kernel.printk = 4 4 1 7

EOF

/sbin/sysctl -p /etc/sysctl.conf
exit $?
