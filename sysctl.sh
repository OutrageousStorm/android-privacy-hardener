#!/bin/bash
# sysctl.sh -- System-level privacy & security hardening via sysctl
# Requires: root or Shizuku
# This script hardens kernel-level settings for privacy
set -e

echo "🔒 System Hardening via sysctl"
echo "This requires root or Shizuku. Running as:"
whoami

# TCP hardening
echo "Setting tcp hardening..."
sysctl -w net.ipv4.conf.all.rp_filter=1
sysctl -w net.ipv4.conf.default.rp_filter=1
sysctl -w net.ipv4.tcp_syncookies=1

# IP spoofing protection
echo "IP spoof protection..."
sysctl -w net.ipv4.conf.all.send_redirects=0
sysctl -w net.ipv4.conf.default.send_redirects=0
sysctl -w net.ipv4.conf.all.accept_redirects=0
sysctl -w net.ipv4.conf.default.accept_redirects=0

# IPv6 hardening
echo "IPv6 hardening..."
sysctl -w net.ipv6.conf.all.disable_ipv6=0
sysctl -w net.ipv6.conf.all.forwarding=0

# ICMP hardening
echo "ICMP hardening..."
sysctl -w net.ipv4.icmp_echo_ignore_all=0
sysctl -w net.ipv4.icmp_ignore_bogus_error_responses=1

echo "✅ Hardening complete"
sysctl -a | grep -E "(rp_filter|syncookies|send_redirects)"
