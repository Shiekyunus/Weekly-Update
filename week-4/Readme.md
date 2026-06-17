# 🌐 Networking Fundamentals — Complete Study Notes

---

## 📘 Overview

This document provides a comprehensive understanding of how computers communicate over networks and how the Internet works internally. It covers networking fundamentals, layered models, DNS, HTTP communication, protocols, packet flow, and troubleshooting concepts based on real-world networking standards (IETF RFCs and TCP/IP architecture).

---

# 1️⃣ Networking Basics

## What is Networking?

Networking is the process of connecting multiple computers or devices to share data and resources.

### Goals of Networking

* Communication between devices
* Resource sharing
* Internet access
* Remote management

---

## Types of Networks

### LAN (Local Area Network)

* Covers small geographic area
* Example: Home or office network
* High speed, low latency

### MAN (Metropolitan Area Network)

* Covers a city or campus
* Connects multiple LANs

### WAN (Wide Area Network)

* Covers large geographic areas
* Example: The Internet

---

## Key Components

* IP Address → identifies device
* MAC Address → identifies hardware
* Router → connects networks
* Switch → connects devices within LAN
* Modem → connects ISP

---

# 2️⃣ Layered Networking Models

Layered models divide communication into logical responsibilities.

---

## OSI Model (7 Layers)

| Layer        | Function                    |
| ------------ | --------------------------- |
| Application  | User services (HTTP, FTP)   |
| Presentation | Encryption & formatting     |
| Session      | Session management          |
| Transport    | Reliable delivery (TCP/UDP) |
| Network      | Routing (IP)                |
| Data Link    | MAC addressing              |
| Physical     | Signal transmission         |

---

## TCP/IP Model

| Layer          | Protocol Examples |
| -------------- | ----------------- |
| Application    | HTTP, DNS, SMTP   |
| Transport      | TCP, UDP          |
| Internet       | IP, ICMP          |
| Network Access | Ethernet          |

---

# 3️⃣ IP Addressing

An IP address uniquely identifies a device on a network.

Example:
192.168.1.10

### Types

* Public IP
* Private IP
* IPv4
* IPv6

---

# 4️⃣ DNS (Domain Name System)

DNS translates human-readable domain names into IP addresses.

Example:
google.com → 142.x.x.x

---

## DNS Resolution Flow

1. Browser cache check
2. OS resolver
3. Recursive DNS server
4. Root server
5. TLD server
6. Authoritative server
7. IP returned

---

## DNS Uses Port

53 (UDP primarily, TCP when required)

---

# 5️⃣ HTTP & HTTPS

HTTP is the protocol used for web communication.

---

## HTTP Request Structure

GET /index.html HTTP/1.1
Host: example.com

Components:

* Method
* Path
* Version
* Headers
* Optional body

---

## HTTP Response Structure

HTTP/1.1 200 OK
Content-Type: text/html

---

## Common HTTP Methods

| Method | Purpose         |
| ------ | --------------- |
| GET    | Retrieve data   |
| POST   | Send data       |
| PUT    | Update resource |
| DELETE | Remove resource |

---

## HTTPS

HTTPS = HTTP + TLS encryption.

Port: 443

Provides:

* Confidentiality
* Authentication
* Integrity

---

# 6️⃣ HTTP Headers

Headers carry metadata about requests and responses.

---

## Request Headers

* Host → requested domain
* User-Agent → client info
* Accept → supported formats
* Authorization → authentication data
* Cookie → session information

---

## Response Headers

* Content-Type → response format
* Content-Length → size
* Server → server software
* Set-Cookie → session creation
* Cache-Control → caching rules

---

## HTTP Status Codes

### Success (2xx)

* 200 OK
* 201 Created

### Redirection (3xx)

* 301 Moved Permanently

### Client Errors (4xx)

* 400 Bad Request
* 404 Not Found

### Server Errors (5xx)

* 500 Internal Server Error

---

# 7️⃣ Network Protocols & Ports

A protocol defines communication rules between systems.

A port identifies a specific application on a device.

---

## Important Protocols

| Protocol | Port   | Purpose         |
| -------- | ------ | --------------- |
| HTTP     | 80     | Web traffic     |
| HTTPS    | 443    | Secure web      |
| DNS      | 53     | Name resolution |
| SSH      | 22     | Remote login    |
| FTP      | 21     | File transfer   |
| SMTP     | 25/587 | Send email      |
| IMAP     | 143    | Retrieve email  |
| POP3     | 110    | Download email  |
| DHCP     | 67/68  | IP assignment   |

---

## TCP vs UDP

| Feature     | TCP      | UDP            |
| ----------- | -------- | -------------- |
| Reliability | Yes      | No             |
| Speed       | Slower   | Faster         |
| Use Cases   | Web, SSH | DNS, Streaming |

---

# 8️⃣ TCP Connection Establishment

TCP uses a 3-way handshake:

1. SYN
2. SYN-ACK
3. ACK

Ensures reliable connection setup.

---

# 9️⃣ Packet Encapsulation

Data is wrapped at each layer:

Ethernet Frame
→ IP Packet
→ TCP Segment
→ HTTP Data

Each layer adds headers.

---

# 🔟 Real Internet Packet Flow

When opening a website:

1. URL entered in browser
2. Browser checks cache
3. DNS lookup performed
4. ARP resolves router MAC
5. TCP handshake established
6. TLS handshake creates encryption
7. HTTP request sent
8. Routers forward packets
9. Server processes request
10. Response returned
11. Browser renders webpage

---

# 11️⃣ Troubleshooting Concepts

Common issue mapping:

| Problem             | Likely Cause                      |
| ------------------- | --------------------------------- |
| Website not loading | DNS/HTTP issue                    |
| Cannot SSH          | Port 22 blocked                   |
| No IP address       | DHCP failure                      |
| Slow website        | Large responses or caching issues |
| Ping fails          | Network connectivity              |

---

## Useful Linux Commands

ping google.com
curl -I https://example.com
ss -tuln
traceroute google.com

---

# 12️⃣ Protocol Stack Example

Opening a webpage uses:

Application → HTTP
Security → TLS
Transport → TCP
Network → IP
Data Link → Ethernet

---

# ✅ Key Learning Outcomes

After studying these topics, you can:

* Understand how the Internet works internally
* Interpret HTTP requests and responses
* Explain DNS resolution
* Identify protocol responsibilities
* Analyze packet flow
* Troubleshoot networking issues
* Understand real-world communication between devices

---

# 📚 References

* RFC 9110 — HTTP Semantics
* RFC 1035 — DNS
* RFC 793 — TCP
* RFC 768 — UDP
* IETF Networking Standards

---

⭐ End of Networking Fundamentals Notes
