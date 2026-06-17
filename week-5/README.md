# Web Servers and HTTPS Notes

---

# Introduction

This document provides a **comprehensive understanding of web servers, DNS, HTTPS, and modern deployment architecture**. It is designed to bridge the gap between **theoretical knowledge and real-world DevOps practices**.

---

# 1. Web Servers

## What is a Web Server?

A **web server** is software (and sometimes hardware) responsible for:

* Receiving HTTP/HTTPS requests from clients (browsers)
* Processing those requests
* Returning appropriate responses (web pages, APIs, files)

---

## Basic Flow

```
Browser → Internet → Web Server → Response → Browser renders page
```
---

## Ports Used

| Port | Protocol |
| ---- | -------- |
| 80   | HTTP     |
| 443  | HTTPS    |

---

## Types of Content

### Static Content

* HTML files
* CSS stylesheets
* JavaScript files
* Images/videos

### Dynamic Content

* Generated at runtime
* Depends on backend logic
* Uses databases and APIs

---

# 2. Popular Web Servers

---

## Nginx

A modern, high-performance web server.

### Features

* Event-driven architecture
* Handles thousands of concurrent connections
* Reverse proxy support
* Load balancing
* Static file optimization

---

## Apache HTTP Server

A traditional, widely used web server.

### Features

* Modular architecture
* Supports `.htaccess`
* Highly customizable
* Large ecosystem

---

## Comparison

| Feature         | Nginx        | Apache         |
| --------------- | ------------ | -------------- |
| Architecture    | Event-driven | Process/thread |
| Performance     | Very high    | Moderate       |
| Static files    | Excellent    | Good           |
| Dynamic support | Proxy based  | Native modules |
| Memory usage    | Low          | Higher         |
| Configuration   | Simple       | Complex        |

---

#  3. Apache Web Server

---

## Apache’s Job

```
Receive HTTP Request
        ↓
Process request using modules
        ↓
Return HTTP Response
```

---

## Capabilities

* Serve static content
* Run backend applications
* Perform authentication
* Rewrite URLs
* Enable HTTPS
* Log requests

---

## Apache Architecture

```
            Apache Core
                 │
   ┌─────────────┼─────────────┐
 Modules     Processing Model   Config System
```

---

## Components

### 1. Core Server

* Starts Apache
* Loads configurations
* Handles networking

---

### 2. Modules

| Module      | Purpose          |
| ----------- | ---------------- |
| mod_http    | HTTP handling    |
| mod_ssl     | HTTPS encryption |
| mod_rewrite | URL rewriting    |
| mod_proxy   | Reverse proxy    |
| mod_php     | PHP execution    |
| mod_headers | Header control   |

---

### 3. MPM (Multi-Processing Modules)

* Prefork (process-based)
* Worker (thread-based)
* Event (modern async)

---

## Directory Structure

```
/etc/apache2/
```

| Path             | Purpose         |
| ---------------- | --------------- |
| apache2.conf     | Main config     |
| ports.conf       | Ports config    |
| sites-available/ | Site configs    |
| sites-enabled/   | Active configs  |
| mods-available/  | Modules         |
| mods-enabled/    | Enabled modules |

---

## Configuration Hierarchy

```
apache2.conf
    ↓
ports.conf
    ↓
modules
    ↓
virtual hosts
    ↓
.htaccess
```

---

# 4. Nginx Web Server

---

## What is Nginx?

Nginx acts as:

* Web server
* Reverse proxy
* Load balancer
* API gateway
* Cache server

---

## Architecture

### Master-Worker Model

```
MASTER PROCESS
     │
 ┌───┼────────────┐
 │   │            │
W1  W2           WN
```

---

## Core Concept

Event-driven asynchronous architecture:

* One worker → thousands of connections
* Non-blocking I/O

---

## Responsibilities

### Master Process

* Reads config
* Starts workers
* Manages lifecycle

---

### Worker Processes

* Handle requests
* Serve files
* Proxy requests
* Manage caching

---

# Request Processing Workflow

```
GET /index.html
Host: example.com
```

### Steps:

1. Accept TCP connection
2. Worker picks connection
3. Parse request
4. Select server block
5. Match location block
6. Execute handler
7. Send response

---

# Configuration Hierarchy

```
Main → Events → HTTP → Server → Location
```

---

# Directory Structure

```
/etc/nginx/
```

| Path             | Purpose          |
| ---------------- | ---------------- |
| nginx.conf       | Main config      |
| sites-available/ | Config files     |
| sites-enabled/   | Active configs   |
| /var/www/html    | Default web root |

---

# 5. Hosting Static Website

---

## Steps

1. Install Nginx
2. Create directory
3. Add HTML file
4. Configure server block
5. Enable site
6. Reload service

---

## Example Configuration

```
server {
    listen 80;
    server_name mysite.com;

    root /var/www/mysite;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

---

# 6. DNS Configuration

---

## What is DNS?

DNS converts:

```
Domain → IP Address
```

---

## Important Records

* A Record → IPv4 mapping
* CNAME → Alias
* AAAA → IPv6

---

## Flow

```
Domain → DNS → IP → Server → Website
```

---

# 7. HTTP vs HTTPS

| Feature    | HTTP | HTTPS |
| ---------- | ---- | ----- |
| Security   | No   | Yes   |
| Encryption | No   | Yes   |
| Port       | 80   | 443   |

---

# 8. SSL/TLS

---

## TLS Handshake

```
Client Hello
→ Server Certificate
→ Key Exchange
→ Secure Connection
```

---

## Setup Steps

1. Install Certbot
2. Generate certificate
3. Configure Nginx
4. Enable auto-renewal

---

## HTTPS Config

```
server {
    listen 443 ssl;
    server_name mysite.com;

    ssl_certificate /path/fullchain.pem;
    ssl_certificate_key /path/privkey.pem;
}
```

---

# 9. Web Server vs Application Server

---

## Comparison

| Feature  | Web Server    | Application Server      |
| -------- | ------------- | ----------------------- |
| Role     | Serve content | Execute logic           |
| Content  | Static        | Dynamic                 |
| Examples | Nginx, Apache | Node.js, Django, Tomcat |

---

## Request Flow

```
Browser
   ↓
Web Server
   ↓
Application Server
   ↓
Database
   ↓
Response
```

---

# 10. Final Production Architecture

```
User
 ↓
DNS
 ↓
Web Server (Nginx)
 ↓
Application Server
 ↓
Database
```
---