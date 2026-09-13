---
name: networking-fundamentals
description: Diagnose connectivity failures — "connection refused/timed out", "can't resolve host", "cert/TLS handshake error", "works locally not in prod" — using DNS/TCP/TLS layer isolation and curl/dig/openssl/traceroute. NOT for writing HTTP client code (use networking-security) or app-level HTTP status/logic bugs (use bug-investigator).
---

# Networking Fundamentals Skill

Use when reasoning about network architecture or diagnosing connectivity, latency, or TLS issues — not for routine HTTP client code (see `~/.claude/rules/networking-security.md`).

## Reference model
- **Layers (simplified TCP/IP)**: Link (Ethernet/Wi-Fi) -> Internet (IP, routing) -> Transport (TCP: reliable/ordered; UDP: unreliable/fast) -> Application (HTTP, DNS; TLS sits between Transport and Application).
- **DNS resolution flow**: client resolver -> recursive resolver (ISP/`8.8.8.8`) -> root -> TLD -> authoritative nameserver -> IP returned and cached per TTL.
- **TLS handshake (high level)**: ClientHello -> ServerHello + certificate -> key exchange -> both sides derive session keys -> encrypted application data. A cert is trusted when its chain reaches a CA in the client's trust store and the hostname matches.
- **Common infra pieces**: load balancer (distributes traffic), reverse proxy (terminates TLS / routes by path-host), CDN (edge-caches static content), firewall/security group (allow/deny by port-IP), NAT (private<->public IP translation).

## Diagnostic workflow
1. **Reproduce and scope**: determine whether it's DNS, connect, TLS, or application-layer (HTTP status/body).
2. **DNS**: `dig <host>` / `nslookup <host>` — confirm resolution and TTL; check for stale caches.
3. **Reachability/latency**: `ping <host>` (ICMP, may be blocked), `traceroute`/`tracert <host>` to find where latency/loss starts.
4. **Port/connect**: `nc -zv <host> <port>` or `curl -v telnet://<host>:<port>` to confirm the port accepts TCP.
5. **TLS**: `curl -v https://<host>` or `openssl s_client -connect host:443 -servername host` for handshake/cert details.
6. **HTTP layer**: `curl -v` to inspect headers, status, body, redirects, auth, and caching.
7. **Local socket/connection state**: `ss -tulpn` (Linux) / `netstat -ano` (Windows); use `tcpdump`/Wireshark when packet detail is required.

## When to use which tool
- Quick "is it up" check -> `curl -v` or `ping`.
- "Where is traffic getting stuck" -> `traceroute`/`tracert`.
- "Is DNS returning what I expect" -> `dig`/`nslookup`.
- "Is TLS/cert the problem" -> `openssl s_client` or `curl -v`.
- "What's listening/connected on this host" -> `ss`/`netstat`.
- "I need packet-level detail" -> `tcpdump`/Wireshark (last resort, more setup).

## Completion checklist
- [ ] Issue is scoped to a specific layer (DNS/connect/TLS/HTTP) before proposing a fix.
- [ ] Diagnosis is backed by actual command output, not assumption.
