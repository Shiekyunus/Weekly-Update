# AWS Learning Notes — VPC & EC2

---

## Topic 1: VPC (Virtual Private Cloud)

### Overview
A **Virtual Private Cloud (VPC)** is a logically isolated section of the AWS Cloud where you can launch AWS resources in a virtual network that you define. It gives you full control over your networking environment — including IP address ranges, subnets, route tables, and gateways.

---

### 1. Public IP, Private IP, IPv4 & IPv6

#### IP Address Basics

An **IP address** is a numerical label assigned to each device in a network. There are two versions in active use:

You can assign IP addresses, both IPv4 and IPv6, to your VPCs and subnets.

You can also bring your public IPv4 addresses and IPv6 GUA addresses to AWS and allocate them to resources in your VPC, such as EC2 instances, NAT gateways, and Network Load Balancers.

| Feature | IPv4 | IPv6 |
|---|---|---|
| Format | 32-bit (e.g., 192.168.1.1) | 128-bit (e.g., 2001:db8::1) |
| Address count | ~4.3 billion | ~340 undecillion |
| Notation | Dotted decimal | Colon-separated hexadecimal |
| NAT required | Often yes | No (addresses are plentiful) |
| AWS support | Full | Supported in VPC (dual-stack) |

#### Public IP vs Private IP

| Aspect | Public IP | Private IP |
|---|---|---|
| Reachable from internet | Yes | No |
| Assigned by | AWS (or ISP) | You (within RFC 1918 ranges) |
| Cost | Dynamic: free; Elastic: charged | Free |
| Persistence | Lost on stop/start (dynamic) | Persists while instance runs |
| Use case | Web servers, bastion hosts | Internal services, databases |

**Private IP RFC 1918 Ranges:**
- `10.0.0.0/8` — large networks
- `172.16.0.0/12` — medium networks
- `192.168.0.0/16` — small/home networks

#### In AWS
- Every EC2 instance gets a **private IP** automatically from its subnet's CIDR.
- A **public IP** is optionally assigned at launch (dynamic — lost when stopped).
- An **Elastic IP (EIP)** is a static public IP you allocate and associate with an instance, persisting across stop/start.
- IPv6 addresses in AWS are globally unique and internet-routable by default.

#### Routing:
Use route tables to determine where network traffic from your subnet or gateway is directed.


#### Route tables

A route table contains a set of rules, called routes, that are used to determine where network traffic from your VPC is directed. You can explicitly associate a subnet with a particular route table. Otherwise, the subnet is implicitly associated with the main route table.

Each route in a route table specifies the range of IP addresses where you want the traffic to go (the destination) and the gateway, network interface, or connection through which to send the traffic (the target).


#### Gateways and endpoints: 
A gateway connects your VPC to another network. For example, use an internet gateway to connect your VPC to the internet. 

Use a VPC endpoint to connect to AWS services privately, without the use of an internet gateway or NAT device.

---

### 2. VPC, CIDR, and Subnets

#### CIDR (Classless Inter-Domain Routing)

When you create a VPC, you must specify an IPv4 CIDR block for the VPC. The allowed block size is between a /16 netmask (65,536 IP addresses) and /28 netmask (16 IP addresses)

You can associate secondary IPv4 CIDR blocks with your VPC. When you associate a CIDR block with your VPC, a route is automatically added to your VPC route tables to enable routing within the VPC.

When you create a VPC, we recommend that you specify a CIDR block from the private IPv4 address ranges as specified in RFC 1918.

RFC 1918 range	Example CIDR block
10.0.0.0 - 10.255.255.255 (10/8 prefix)	10.0.0.0/16
172.16.0.0 - 172.31.255.255 (172.16/12 prefix)	172.31.0.0/16
192.168.0.0 - 192.168.255.255 (192.168/16 prefix)	192.168.0.0/20

CIDR notation expresses an IP range: `<base IP>/<prefix length>`

- `/16` → 65,536 addresses (e.g., `10.0.0.0/16`)
- `/24` → 256 addresses (e.g., `10.0.1.0/24`)
- `/32` → 1 address (single host)

AWS **reserves 5 IPs** in every subnet (first 4 + last 1):
- `.0` — Network address
- `.1` — VPC router
- `.2` — AWS DNS
- `.3` — Reserved for future use
- `.255` — Broadcast address (not used, but reserved)

So a `/24` subnet gives you **251 usable IPs**.

#### VPC

- A VPC is scoped to a **single AWS Region**.
- You define the IPv4 CIDR block (e.g., `10.0.0.0/16`). AWS allows `/16` to `/28`.
- A **default VPC** exists in every region with a `172.31.0.0/16` CIDR.
- You can have up to **5 VPCs per region** (soft limit, can be increased).

#### Subnets

A **subnet** is a subdivision of a VPC tied to a single **Availability Zone (AZ)**.

| Type | Internet accessible | Common use |
|---|---|---|
| Public subnet | Yes (via IGW) | Web servers, load balancers, bastion |
| Private subnet | No (unless via NAT) | App servers, databases, internal services |

- Subnets do not span AZs.
- A subnet's CIDR must be a subset of the VPC's CIDR.
- The **"auto-assign public IP"** setting on a subnet determines if instances launched there get a public IP by default.

---

### 3. NACLs and Security Groups

Both control traffic, but at different layers:

| Feature | NACL | Security Group |
|---|---|---|
| Operates at | Subnet level | Instance (ENI) level |
| Statefulness | **Stateless** | **Stateful** |
| Rule types | Allow and Deny | Allow only |
| Rule evaluation | In order (lowest number first) | All rules evaluated together |
| Applies to | All instances in the subnet | Only associated instances |
| Default behavior | Default NACL allows all; Custom NACL denies all | Allows no inbound; allows all outbound |

#### NACL (Network Access Control List)

- Acts as a firewall at the **subnet boundary**.
- Rules are numbered; lowest number is evaluated first.
- Because it is **stateless**, you must explicitly allow both inbound AND outbound traffic (including ephemeral ports 1024–65535 for return traffic).
- One NACL can be associated with multiple subnets, but each subnet has only one NACL.

**Ephemeral ports** (important for NACLs): When a client connects to a server, the OS assigns a random high port (1024–65535) for the response. Your NACL outbound rules must allow these.

#### Security Groups

- Acts as a virtual firewall at the **instance level**.
- Because it is **stateful**, if you allow inbound traffic, the return traffic is automatically allowed — no need for an explicit outbound rule for responses.
- You can reference **other security groups** as sources/destinations (e.g., allow traffic from the web server SG to the DB SG).
- Up to 5 security groups can be attached to an ENI.

#### When to use which?

- Use **Security Groups** as your primary line of defense (stateful, easier to manage).
- Use **NACLs** for a broad subnet-level block (e.g., blocking a known malicious IP range or an entire port across the subnet).

---

### 4. NAT Gateway, Internet Gateway, and Route Tables

#### Internet Gateway (IGW)

- A **horizontally scaled, redundant, highly available** VPC component.
- Allows communication between instances in a VPC and the internet.
- Must be **attached to a VPC** and referenced in a route table.
- Performs **NAT** for instances with public IPs.
- Needed for any subnet to be "public."

#### NAT Gateway

- Allows **private subnet instances** to initiate outbound connections to the internet (e.g., to download packages) **without being reachable inbound from the internet**.
- Deployed in a **public subnet** and associated with an **Elastic IP**.
- AWS managed — highly available within an AZ.
- **Not free** — charged per hour and per GB of data processed.

| Feature | Internet Gateway | NAT Gateway |
|---|---|---|
| Direction | Bidirectional | Outbound only (from private) |
| Used by | Public subnet instances | Private subnet instances |
| Public IP required | Instance needs one | NAT GW has EIP |
| Cost | Free | Charged per hour + data |
| HA | Region-wide | Per-AZ (deploy one per AZ for full HA) |

#### NAT Instance (Legacy alternative to NAT Gateway)

- An EC2 instance configured to do NAT.
- Requires disabling **source/destination check**.
- Not recommended — you manage it; not highly available by default.

#### Route Tables

A **route table** contains a set of rules (routes) that determine where network traffic is directed.

- Every subnet is associated with one route table.
- A route table can be associated with multiple subnets.
- The **main route table** is automatically created with the VPC.

**Route Table for a Public Subnet:**
```
Destination     Target
10.0.0.0/16     local        ← VPC-internal traffic
0.0.0.0/0       igw-xxxxxxx  ← Internet-bound traffic goes to IGW
```

**Route Table for a Private Subnet (with NAT Gateway):**
```
Destination     Target
10.0.0.0/16     local        ← VPC-internal traffic
0.0.0.0/0       nat-xxxxxxx  ← Internet-bound traffic goes to NAT GW
```

**Route Table for a Private Subnet (without NAT Gateway):**
```
Destination     Target
10.0.0.0/16     local        ← Only VPC-internal traffic; no internet access
```

#### Internet Traffic Flow — Public Instance
```
Internet → IGW → Public Subnet → EC2 (has Public IP)
EC2 → Public Subnet → IGW → Internet
```

#### Internet Traffic Flow — Private Instance (via NAT)
```
Private EC2 → Private Route Table → NAT GW (in public subnet) → IGW → Internet
Response: Internet → IGW → NAT GW → Private EC2
(Inbound connections from internet are blocked — NAT GW drops unsolicited inbound)
```

---
## Expectation 1: Explain the Use Cases and Differences Between NACLs and Security Groups
 
### The Core Difference in One Line
- **Security Group** = Firewall around an **EC2 instance** (stateful — remembers connections)
- **NACL** = Firewall around a **Subnet** (stateless — does not remember connections)
---
 
### Detailed Comparison
 
| Feature | Security Group | NACL |
|---|---|---|
| Level | Instance (ENI) | Subnet |
| Statefulness | **Stateful** | **Stateless** |
| Rule types | Allow only | Allow AND Deny |
| Rule evaluation | All rules at once | Numbered order (lowest first) |
| Default (custom) | Deny all inbound, allow all outbound | Deny all inbound and outbound |
| Applies to | Only instances you attach it to | All instances in the subnet |
| Can reference SGs | Yes | No |
 
---
 
### Stateful vs Stateless — What It Really Means
 
**Security Group (Stateful):**
You allow port 80 inbound. A user sends a request. The response automatically goes back — you do NOT need a rule for the return traffic. AWS tracks the connection.
 
```
User → [port 80 inbound ALLOWED] → EC2
EC2 → [response on ephemeral port — automatically allowed] → User ✅
```
 
**NACL (Stateless):**
You allow port 80 inbound. A user sends a request. The response is on an ephemeral port (e.g., 32768). You must ALSO explicitly allow outbound ephemeral ports (1024–65535), or the response is blocked.
 
```
User → [port 80 inbound rule #100 ALLOW] → EC2
EC2 → [ephemeral port outbound — BLOCKED unless you allow 1024-65535 outbound] ❌
```
 
---
 
### When to Use Each
 
**Use Security Groups for:**
- Controlling access to individual EC2 instances, RDS databases, Lambda functions
- Allowing one SG to reference another (e.g., allow DB SG to accept from Web SG only)
- Day-to-day access control — this is your primary tool
**Use NACLs for:**
- Blocking a specific IP range at the subnet level (e.g., blocking a malicious CIDR block)
- Adding an extra layer of defense on top of Security Groups
- Enforcing a blanket deny across all instances in a subnet
**Real-world example:**
You have a web subnet with 10 EC2 instances. You discover a DDoS from `1.2.3.0/24`. You add a NACL Deny rule for that CIDR — it blocks traffic before it even reaches any instance's Security Group. If you used Security Groups, you'd have to update all 10.
 
---
 
### NACL Rule Evaluation Example
 
```
Rule #  | Type     | Protocol | Port  | Source      | Allow/Deny
--------|----------|----------|-------|-------------|----------
100     | HTTP     | TCP      | 80    | 0.0.0.0/0   | ALLOW
200     | HTTPS    | TCP      | 443   | 0.0.0.0/0   | ALLOW
300     | SSH      | TCP      | 22    | 10.0.0.0/16 | ALLOW
*       | All      | All      | All   | 0.0.0.0/0   | DENY  ← catches everything else
```
 
Rules are evaluated **top to bottom**. First match wins. The `*` rule is the implicit deny at the end.

## Expectation 3: Internet Traffic Flow — Step by Step
 
### Flow 1: Public Instance Communicating with the Internet
 
**Scenario:** A user opens `http://<public-ip>` to reach the web server on the public EC2.
 
```
Step 1:  User's browser sends HTTP request to the EC2's Public IP (e.g., 54.12.34.56)
Step 2:  Request arrives at the Internet Gateway (IGW) attached to the VPC
Step 3:  IGW performs 1:1 NAT — translates destination from Public IP → Private IP (10.0.1.10)
Step 4:  Request enters the VPC and is routed to the public subnet
Step 5:  Public subnet's route table matches 10.0.0.0/16 → local → delivers to EC2 (10.0.1.10)
Step 6:  EC2's Security Group checks: is port 80 inbound allowed? YES → packet delivered
Step 7:  EC2 processes the request and sends HTTP response
Step 8:  Response goes back through IGW (private IP → public IP NAT reversal)
Step 9:  Response reaches the user's browser
```
 
### Flow 2: Private Instance Initiating Outbound Internet Traffic (via NAT)
 
**Scenario:** The private EC2 runs `yum update` — needs to reach the internet to download packages.
 
```
Step 1:  Private EC2 (10.0.2.10) sends packet to yum repo (e.g., 99.84.1.1)
Step 2:  Private EC2 checks its route table:
         - 10.0.0.0/16 → local (not this)
         - 0.0.0.0/0 → nat-gateway-id  ← matches
Step 3:  Packet is forwarded to the NAT Gateway (which sits in the public subnet at 10.0.1.5)
Step 4:  NAT Gateway replaces the source IP (10.0.2.10) with its own Elastic IP (e.g., 3.45.67.89)
         and records the mapping in its NAT table
Step 5:  NAT Gateway sends the packet through the public subnet's route table → IGW
Step 6:  IGW routes the packet to the internet
Step 7:  Response comes back to the Elastic IP (3.45.67.89)
Step 8:  NAT Gateway looks up its NAT table → finds the mapping → restores destination to 10.0.2.10
Step 9:  Packet is delivered back to the private EC2
```
 
**Key point:** At no point does the internet know about `10.0.2.10`. Only the NAT Gateway's EIP is visible externally. No inbound connection can be initiated from outside.
 
---
 
## Expectation 4: Cost Estimation for Custom VPC Architecture
 
All prices are for **us-east-1** (N. Virginia) as of 2024. Always verify at aws.amazon.com/pricing.
 
### Resources and Their Costs
 
| Resource | Cost | Notes |
|---|---|---|
| VPC | **Free** | No charge for the VPC itself |
| Subnets | **Free** | No charge per subnet |
| Internet Gateway | **Free** | No hourly charge; data transfer costs apply |
| Route Tables | **Free** | No charge |
| Security Groups | **Free** | No charge |
| NACLs | **Free** | No charge |
| NAT Gateway | **$0.045/hr** + **$0.045/GB processed** | Most expensive VPC component |
| Elastic IP | **Free** when attached to running instance | $0.005/hr if idle or unattached |
| EC2 t2.micro (On-Demand) | **~$0.0116/hr** | ~$8.47/month |
| EBS gp3 (8 GB root) | **$0.08/GB/month** | ~$0.64/month per instance |
 
---
 
### Monthly Cost Estimate (running 24/7 for 30 days)
 
```
NAT Gateway:
  Hourly:       0.045 × 24 × 30     = $32.40
  Data (10 GB): 0.045 × 10          = $0.45
  Subtotal:                          = $32.85
 
EC2 Public (t2.micro, On-Demand):
  0.0116 × 24 × 30                  = $8.47
  EBS 8GB gp3: 0.08 × 8            = $0.64
  Subtotal:                          = $9.11
 
EC2 Private (t2.micro, On-Demand):
  0.0116 × 24 × 30                  = $8.47
  EBS 8GB gp3: 0.08 × 8            = $0.64
  Subtotal:                          = $9.11
 
Elastic IP (attached to running instance): $0.00
 
Data Transfer (outbound to internet):
  First 100 GB/month                = $0.09/GB
  Example: 5 GB × 0.09             = $0.45
 
─────────────────────────────────────────────
TOTAL ESTIMATE (monthly):           ~$51.52
─────────────────────────────────────────────
```
 
### Cost Optimization Tips
- **Use t3.micro instead of t2.micro** — same free tier, better performance
- **Turn off NAT Gateway when not needed** — NAT GW is the biggest cost. For dev/test, consider a NAT Instance on t2.micro (free tier eligible) instead
- **Use Free Tier** — for the first 12 months: 750 hrs/month of t2.micro or t3.micro are free
- **Reserved Instances** — 1-year RI for t3.micro saves ~40% on EC2 cost
---
 
## Expectation 5: Create Custom VPC Components via AWS Console — Step-by-Step
 
### Step 1: Create the VPC
1. Go to **VPC → Your VPCs → Create VPC**
2. Select **VPC only** (not VPC and more)
3. Set:
   - Name: `custom-vpc`
   - IPv4 CIDR: `10.0.0.0/16`
   - Tenancy: Default
4. Click **Create VPC**
### Step 2: Create the Public Subnet
1. Go to **VPC → Subnets → Create subnet**
2. Select your `custom-vpc`
3. Set:
   - Name: `public-subnet`
   - AZ: `us-east-1a`
   - IPv4 CIDR: `10.0.1.0/24`
4. Click **Create subnet**
5. Select the subnet → **Actions → Edit subnet settings** → enable **Auto-assign public IPv4 address**
### Step 3: Create the Private Subnet
1. Same as above:
   - Name: `private-subnet`
   - AZ: `us-east-1b`
   - IPv4 CIDR: `10.0.2.0/24`
2. Do **NOT** enable auto-assign public IP
### Step 4: Create and Attach the Internet Gateway
1. Go to **VPC → Internet Gateways → Create internet gateway**
2. Name: `custom-igw` → **Create**
3. Select the IGW → **Actions → Attach to VPC** → select `custom-vpc` → **Attach**
### Step 5: Create an Elastic IP for NAT Gateway
1. Go to **EC2 → Elastic IPs → Allocate Elastic IP address**
2. Keep defaults → **Allocate**
3. Note the IP address — this will be the NAT GW's public IP
### Step 6: Create the NAT Gateway
1. Go to **VPC → NAT Gateways → Create NAT gateway**
2. Set:
   - Name: `custom-nat-gw`
   - Subnet: `public-subnet` ← **must be the public subnet**
   - Connectivity type: Public
   - Elastic IP: select the one you just allocated
3. Click **Create NAT gateway**
4. Wait for status to become **Available** (takes 1–2 minutes)
### Step 7: Configure Route Tables
 
**Public Route Table:**
1. Go to **VPC → Route Tables** → find the main route table for your VPC
2. **Actions → Edit routes → Add route**:
   - Destination: `0.0.0.0/0`
   - Target: select **Internet Gateway** → `custom-igw`
3. Save → go to **Subnet associations tab → Edit → associate `public-subnet`**
**Private Route Table:**
1. **Create route table**:
   - Name: `private-rt`
   - VPC: `custom-vpc`
2. **Edit routes → Add route**:
   - Destination: `0.0.0.0/0`
   - Target: select **NAT Gateway** → `custom-nat-gw`
3. **Subnet associations → associate `private-subnet`**
### Step 8: Create Security Groups
 
**Public SG:**
1. **EC2 → Security Groups → Create security group**
2. Name: `public-sg`, VPC: `custom-vpc`
3. Inbound rules:
   - SSH (22) from `0.0.0.0/0`
   - HTTP (80) from `0.0.0.0/0`
4. Outbound: Allow all (default)
**Private SG:**
1. Name: `private-sg`, VPC: `custom-vpc`
2. Inbound rules:
   - SSH (22) from Source: **Custom** → select `public-sg`
3. Outbound: Allow all (default)
### Step 9: Launch EC2 Instances
 
**Public EC2:**
1. **EC2 → Launch instance**
2. Name: `public-ec2`
3. AMI: Amazon Linux 2
4. Instance type: t2.micro
5. Key pair: select or create one
6. Network settings: Edit →
   - VPC: `custom-vpc`
   - Subnet: `public-subnet`
   - Auto-assign public IP: Enable
   - Security group: `public-sg`
7. Launch
**Private EC2:**
1. Same steps but:
   - Name: `private-ec2`
   - Subnet: `private-subnet`
   - Auto-assign public IP: Disable
   - Security group: `private-sg`
2. Launch
### Step 10: Verify
- SSH into public EC2: `ssh -i your-key.pem ec2-user@<public-ip>`
- From public EC2, SSH into private EC2: `ssh -i your-key.pem ec2-user@<private-ip-of-private-ec2>`
- From private EC2, test internet access: `curl https://www.google.com` — should work (via NAT)

--- 
---

## Topic 2: EC2 (Elastic Compute Cloud)

### Overview
**Amazon EC2** provides resizable virtual servers (instances) in the cloud. You have full control over compute capacity — choosing the OS, instance type, storage, networking, and security configuration.

---

### 1. AMI, Instance Types, and Key Pairs

#### AMI (Amazon Machine Image)

An **AMI** is a template containing the OS, application server, and application needed to launch an EC2 instance.

**AMI includes:**
- Root volume snapshot (OS + software)
- Launch permissions (who can use it)
- Block device mapping (which volumes to attach at launch)

**AMI types by source:**
| Type | Description |
|---|---|
| AWS-provided | Amazon Linux 2, Ubuntu, Windows Server, etc. |
| AWS Marketplace | Pre-configured by third-party vendors (e.g., NGINX, Bitnami) |
| Community AMIs | Shared publicly by other AWS users |
| Custom (your own) | Created by you from an existing instance |

**AMI is region-specific** — you must copy an AMI to use it in another region.

#### Instance Types

EC2 instances are grouped into **families** based on use case:

| Family | Optimized for | Example types |
|---|---|---|
| **General Purpose** | Balanced compute/memory/network | t3, t4g, m6i, m7g |
| **Compute Optimized** | High CPU workloads, HPC, gaming | c6i, c7g |
| **Memory Optimized** | Large in-memory databases, caches | r6i, x2idn, u-6tb1 |
| **Storage Optimized** | High sequential read/write, NoSQL | i4i, d3, h1 |
| **Accelerated Computing** | ML inference, video encoding, GPU | p4, g5, inf2, trn1 |

**Instance naming convention:** `m6i.xlarge`
- `m` → family (general purpose)
- `6` → generation
- `i` → processor attribute (Intel)
- `xlarge` → size (vCPUs and RAM)

**Burstable instances (T-family):**
- Earn **CPU credits** when idle; spend them during bursts.
- `T3` is standard; `T4g` is Graviton (ARM, ~20% cheaper).
- Useful for dev/test workloads with variable CPU.

#### Key Pairs

A **key pair** consists of a public key (AWS stores it) and a private key (you download it — `.pem` file). Used for SSH access to Linux instances (or decrypting the Windows admin password).

- **RSA** or **ED25519** key types supported.
- The private key (`.pem`) is shown **only once** at creation — save it immediately.
- For SSH: `ssh -i "my-key.pem" ec2-user@<public-ip>`
- **Best practice:** Use a separate key pair per environment (dev/staging/prod).
- Lost your `.pem`? You must replace the public key on the instance manually or create a new instance.

#### Steps to create a EC2

1.  AMI(Amazon machine image)
    it is a template that is used to create a new instance/machine based on the user requirement.
    Contains: 
        Software info
        OS info
        Volume info
        Access permission
    Types:
        predefined
        Custom

2. Choosing instance type
    This specifes the hardware specifications.They are fixed and their configurations can't be changed. 

    * Compute optimized
    * Memory optimized
    * GPU optimized
    * Storage optimized
    * General purpose

3. Configure instance

4. Add storage
    * Ephermeral storage
    * EBS
    * S3

5. Add tags

---

### 2. Pricing Models and Launch Templates

#### EC2 Pricing Models

| Model | Discount vs On-Demand | Commitment | Best for |
|---|---|---|---|
| **On-Demand** | None (baseline) | None | Short-term, unpredictable workloads |
| **Reserved Instances (RI)** | Up to 72% | 1 or 3 years | Steady-state production workloads |
| **Savings Plans** | Up to 66% | 1 or 3 years | Flexible (applies across instance families/regions) |
| **Spot Instances** | Up to 90% | None | Fault-tolerant, flexible, batch jobs |
| **Dedicated Hosts** | Varies | On-demand or reserved | Compliance, BYOL (Bring Your Own License) |
| **Dedicated Instances** | Slightly less than Dedicated Hosts | On-demand or reserved | Isolation at hardware level |
| **Capacity Reservations** | None | None (pay regardless of use) | Guaranteed capacity in a specific AZ |

**Reserved Instance sub-types:**
- **Standard RI** — highest discount, cannot change instance family.
- **Convertible RI** — can change instance type/family, ~54% discount.

**Spot Instance behavior:**
- AWS can **reclaim** a Spot instance with a **2-minute warning** when capacity is needed.
- Ideal for: big data, CI/CD, stateless web, video rendering.
- Combine with On-Demand via **Spot Fleet** or **EC2 Auto Scaling** for resilient architectures.

#### Launch Templates

A **Launch Template** is a versioned configuration document that stores all the parameters needed to launch an EC2 instance.

**What it stores:**
- AMI ID
- Instance type
- Key pair
- Security groups
- Subnet/VPC
- IAM instance profile
- User data (bootstrap script)
- EBS volume configuration
- Tags
- Placement groups

**Launch Template vs Launch Configuration:**
| Feature | Launch Template | Launch Configuration (legacy) |
|---|---|---|
| Versioning | Yes | No |
| Mixed instance types | Yes | No |
| Spot + On-Demand mix | Yes | No |
| Recommended | Yes | No (deprecated in favor of LT) |

**Use cases:** Auto Scaling Groups, EC2 Fleet, Spot Fleet, manual launches with consistent config.

---

### 3. EBS, EFS, and Instance Store

#### EBS (Elastic Block Store)

- **Network-attached block storage** — like a virtual hard drive for EC2.
- Tied to a **single AZ** — must be in the same AZ as the instance.
- **Persistent** — survives instance stop/terminate (unless "Delete on termination" is enabled).
- Can be **detached** and **re-attached** to another instance.
- Supports **encryption** at rest using AWS KMS.

**EBS Volume Types:**

| Type | Use case | Max IOPS | Max throughput |
|---|---|---|---|
| gp3 (General Purpose SSD) | Boot, most workloads | 16,000 | 1,000 MB/s |
| gp2 (General Purpose SSD) | Older gen, boot | 16,000 | 250 MB/s |
| io1/io2 (Provisioned IOPS SSD) | Databases needing high IOPS | 64,000 / 256,000 | 1,000 / 4,000 MB/s |
| st1 (Throughput Optimized HDD) | Big data, log processing | 500 | 500 MB/s |
| sc1 (Cold HDD) | Infrequent access, archival | 250 | 250 MB/s |

**gp3 is the recommended default** — you set IOPS and throughput independently, unlike gp2 which ties IOPS to volume size.

#### EFS (Elastic File System)

- **Managed NFS (Network File System)** — shared file storage.
- Can be mounted on **multiple EC2 instances simultaneously** across multiple AZs.
- **Elastic** — grows and shrinks automatically as you add/remove files.
- **Regional** — available across all AZs in a region.
- Higher cost than EBS per GB.
- **Use cases:** Shared content, CMS, home directories, DevOps shared configs.

**EFS Storage Classes:**
- **Standard** — frequently accessed files.
- **Infrequent Access (IA)** — lower cost; files not accessed recently are moved automatically via lifecycle policy.

#### Instance Store

- **Physically attached storage** directly on the host server running your instance.
- **Extremely high I/O** — no network overhead.
- **Ephemeral** — data is **lost** when the instance is stopped, terminated, or fails (hibernation does not preserve instance store).
- Cannot be detached or reattached.
- **Use cases:** Buffers, caches, scratch data, temp files, replicated data (e.g., a Kafka broker where data is replicated elsewhere).

**Comparison Summary:**

| Feature | EBS | EFS | Instance Store |
|---|---|---|---|
| Type | Block | File (NFS) | Block |
| Persistence | Yes | Yes | No (ephemeral) |
| Multi-instance | No (1 at a time, except io1/io2 Multi-Attach) | Yes | No |
| Scope | Single AZ | Multi-AZ (regional) | Instance host |
| Performance | High (depends on type) | Variable | Highest |
| Cost | Moderate | Higher | Included in instance price |
| Snapshots | Yes | Backup via AWS Backup | No |

---

### 4. Snapshots of EBS and EC2

#### EBS Snapshots

- A **point-in-time backup** of an EBS volume stored in **S3** (managed by AWS, not in your bucket directly).
- **Incremental** — only blocks changed since the last snapshot are saved, reducing cost and time.
- Can be used to: restore a volume, copy volumes across AZs or regions, share with other accounts.
- **Snapshot lifecycle** can be automated using **Amazon Data Lifecycle Manager (DLM)**.

**Key operations:**
- Create a snapshot from a running instance (application-consistent snapshots recommended by first flushing the OS buffer or stopping the instance).
- Restore: Create a new EBS volume from the snapshot (can be in any AZ in the same region).
- Copy snapshot to another region for disaster recovery.
- **Fast Snapshot Restore (FSR)** — pre-warms the snapshot so the restored volume delivers full IOPS immediately (without lazy loading from S3). Extra cost applies.

#### EC2 AMI (Instance) Snapshots

- Creating an AMI from a running instance = **AMI creation**, which internally takes EBS snapshots of all attached volumes.
- Useful for: creating a golden image, auto-scaling with a pre-configured image, disaster recovery.
- **Recycle Bin** — a feature to recover accidentally deleted snapshots or AMIs within a retention period.

---

### 5. EBS Encryption

- Uses **AWS KMS (Key Management Service)** to encrypt data.
- Encryption is applied to: data at rest, data in transit between the instance and EBS, all snapshots, and volumes created from those snapshots.
- **Encryption is transparent** — no changes to applications or OS required.
- Enabled at volume creation — **cannot encrypt an existing unencrypted volume directly**.

**How to encrypt an existing volume:**
1. Create a snapshot of the unencrypted volume.
2. Copy the snapshot and enable encryption during the copy.
3. Create a new volume from the encrypted snapshot.
4. Attach the new volume to the instance and detach the old one.

**Default encryption:** You can enable "EBS encryption by default" at the account/region level — all new volumes will be encrypted automatically.

- **AWS managed key** (`aws/ebs`) — default, no charge beyond KMS API calls.
- **Customer managed key (CMK)** — you control rotation and access policies; additional cost.

---

### 6. Elastic IP and Instance Profile/Role

#### Elastic IP (EIP)

- A **static public IPv4 address** allocated to your AWS account.
- Can be associated with an EC2 instance or a network interface.
- **Persists** even when the instance is stopped or restarted (unlike dynamic public IPs).
- Can be **remapped** to another instance quickly (useful for failover — redirect traffic to a standby instance).

**Cost model:**
- Free when **associated with a running instance**.
- Charged (~$0.005/hr) when **not associated** or associated with a **stopped** instance (to discourage hoarding).
- Up to **5 EIPs per region** by default (soft limit).

**Use cases:** Static DNS mapping, whitelisted IPs in firewalls, failover architecture.

#### IAM Instance Profile / Instance Role

An **Instance Profile** is a container for an IAM role that you attach to an EC2 instance. This allows the instance (and code running on it) to make AWS API calls **without hardcoding credentials**.

**How it works:**
- Attach an IAM role (via instance profile) to an EC2 instance.
- The EC2 instance metadata service (`http://169.254.169.254/latest/meta-data/iam/security-credentials/<role-name>`) provides **temporary credentials** that are automatically rotated.
- AWS SDKs and CLIs pick these up automatically — no `aws configure` needed.

**Best practices:**
- Use **least privilege** — grant only permissions the instance needs.
- Use **condition keys** to restrict access further (e.g., `aws:RequestedRegion`).
- Never hardcode `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` in an instance.

**Example IAM policy for an EC2 instance that should only read from S3:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::my-bucket",
        "arn:aws:s3:::my-bucket/*"
      ]
    }
  ]
}
```

---

## Quick Reference — AWS Console Paths

| Resource | Console Path |
|---|---|
| Create VPC | VPC → Your VPCs → Create VPC |
| Create Subnet | VPC → Subnets → Create subnet |
| Create IGW | VPC → Internet Gateways → Create |
| Create NAT GW | VPC → NAT Gateways → Create |
| Edit Route Table | VPC → Route Tables → Routes tab → Edit routes |
| Create Security Group | EC2 → Security Groups → Create |
| Create NACL | VPC → Network ACLs → Create |
| Launch EC2 | EC2 → Instances → Launch instance |
| Create EBS Volume | EC2 → Volumes → Create volume |
| Create Snapshot | EC2 → Snapshots → Create snapshot |
| Allocate EIP | EC2 → Elastic IPs → Allocate |
| Create IAM Role | IAM → Roles → Create role → EC2 use case |
| Create Launch Template | EC2 → Launch Templates → Create |

---

## Expectation 1: EC2 Purchase Options — Explained with Real-World Scenarios
 
### 1. On-Demand
**What it is:** Pay by the second/hour. No commitment. Full price.
 
**Real-world scenario:**
Your startup just launched. You don't know traffic patterns yet. You spin up On-Demand instances — if traffic spikes, you scale up; if it drops, you scale down. No wasted money on unused reserved capacity.
 
**Other scenarios:** Short-term data processing jobs, development environments you turn off at night, testing a new application architecture.
 
---
 
### 2. Reserved Instances (RI)
**What it is:** Commit to a 1 or 3 year term. Pay upfront (partial/full/none) for up to 72% discount.
 
**Real-world scenario:**
Your e-commerce platform always runs 5 `m5.large` instances in production regardless of traffic. You've been running them for 6 months and know they'll run for years. Buy 1-year Standard RIs — you save ~40% vs On-Demand, which is thousands of dollars per year.
 
**Payment options:**
- All Upfront → highest discount
- Partial Upfront → middle ground
- No Upfront → smallest discount but no upfront cost
---
 
### 3. Savings Plans
**What it is:** Commit to a dollar amount of usage per hour (e.g., $10/hr) for 1 or 3 years. More flexible than RIs — applies across instance families, regions, and even Lambda/Fargate.
 
**Real-world scenario:**
You use a mix of EC2 instances — some `c5`, some `m5`, some in us-east-1, some in eu-west-1. You can't predict exactly which instance type you'll need next year, but you know you'll spend at least $50/hr on compute. A Savings Plan covers all of it with ~66% savings.
 
**Two types:**
- **Compute Savings Plan** — most flexible, applies to EC2 + Fargate + Lambda
- **EC2 Instance Savings Plan** — tied to a specific instance family + region, higher discount
---
 
### 4. Spot Instances
**What it is:** Use spare AWS capacity at up to 90% discount. AWS can reclaim with 2-minute warning.
 
**Real-world scenario:**
A media company runs video transcoding jobs every night — converting raw footage to multiple resolutions. The job takes 4 hours and is fault-tolerant (can be restarted if interrupted). They use Spot Instances, saving 80% compared to On-Demand. If AWS reclaims a Spot instance mid-job, the job checkpoint resumes on a new instance.
 
**Good for:** Batch processing, CI/CD pipelines, machine learning training, genomics, rendering.
**Bad for:** Databases, stateful applications, anything that can't tolerate interruption.
 
---
 
### 5. Dedicated Hosts
**What it is:** An entire physical server dedicated to you. You can bring your own software licenses (BYOL) tied to physical cores/sockets.
 
**Real-world scenario:**
A financial company uses Oracle Database licenses that are tied to physical CPU cores under their enterprise agreement. Running Oracle on shared AWS infrastructure would require new licenses. A Dedicated Host lets them use their existing per-core licenses legally, saving hundreds of thousands in licensing fees.
 
**Other scenario:** Compliance requirements that mandate no multi-tenancy (e.g., certain healthcare or government regulations).
 
---
 
### 6. Dedicated Instances
**What it is:** Your instances run on hardware dedicated to your account — but AWS manages which physical server. Unlike Dedicated Hosts, you don't get visibility into the physical server.
 
**Real-world scenario:**
A company needs hardware isolation for compliance but doesn't have BYOL concerns. Dedicated Instances are cheaper than Dedicated Hosts and provide the isolation required without managing the physical server.
 
---
 
### 7. Capacity Reservations
**What it is:** Reserve EC2 capacity in a specific AZ without a commitment period. You pay for the capacity regardless of whether you use it.
 
**Real-world scenario:**
A financial trading company knows their end-of-quarter processing job needs 50 `c5.4xlarge` instances for exactly 3 days. They create a Capacity Reservation one week in advance to guarantee the capacity will be available. They won't lose jobs due to insufficient capacity during peak AWS demand periods.
 
---
 
### Summary Decision Tree
 
```
Do you need the instance 24/7 for 1+ years?
  YES → Reserved Instance or Savings Plan
  NO  → Is the workload fault-tolerant?
          YES → Spot Instance
          NO  → On-Demand
 
Do you have license compliance needs?
  YES → Dedicated Host
 
Do you need guaranteed capacity at a specific time?
  YES → Capacity Reservation
```
 
---
## Expectation 2: Provision EC2 with Custom Launch Template — Full Terraform
 
This builds on the VPC from Topic 1. It creates:
- An IAM role + instance profile
- A Launch Template with AMI, SG, EIP, user data, and instance profile
- An EC2 instance launched from the template into the custom VPC
```hcl
# ─────────────────────────────────────────
# IAM ROLE FOR EC2 (Instance Profile)
# ─────────────────────────────────────────
 
# Trust policy — allows EC2 service to assume this role
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
 
# Create the IAM role
resource "aws_iam_role" "ec2_role" {
  name               = "ec2-custom-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
 
  tags = {
    Name = "ec2-custom-role"
  }
}
 
# Attach a policy — allow EC2 to read from S3
resource "aws_iam_role_policy" "ec2_s3_read" {
  name = "ec2-s3-read-policy"
  role = aws_iam_role.ec2_role.id
 
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = ["arn:aws:s3:::*"]
      }
    ]
  })
}
 
# Also attach SSM policy — allows AWS Systems Manager access (no SSH needed)
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
 
# Create the Instance Profile (wrapper around IAM role for EC2)
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}
 
# ─────────────────────────────────────────
# SECURITY GROUP (referencing the custom VPC)
# ─────────────────────────────────────────
resource "aws_security_group" "lt_sg" {
  name        = "launch-template-sg"
  description = "Security group for launch template EC2"
  vpc_id      = aws_vpc.main.id   # Custom VPC from Topic 1
 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  tags = {
    Name = "lt-sg"
  }
}
 
# ─────────────────────────────────────────
# LAUNCH TEMPLATE
# ─────────────────────────────────────────
resource "aws_launch_template" "custom_lt" {
  name        = "custom-launch-template"
  description = "Launch template for public EC2 with role, SG, and user data"
 
  # AMI — Amazon Linux 2
  image_id = var.ami_id
 
  # Instance type
  instance_type = "t2.micro"
 
  # Key pair for SSH
  key_name = var.key_name
 
  # IAM Instance Profile
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }
 
  # Network interface configuration
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.lt_sg.id]
    subnet_id                   = aws_subnet.public.id  # Custom VPC public subnet
    delete_on_termination       = true
  }
 
  # EBS root volume
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20         # 20 GB
      volume_type           = "gp3"
      iops                  = 3000       # gp3 baseline
      throughput            = 125        # MB/s
      encrypted             = true       # Enable encryption
      delete_on_termination = true
    }
  }
 
  # User data — runs on first boot
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd aws-cli
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Launched via Custom Launch Template</h1>" > /var/www/html/index.html
    # Verify IAM role is working
    aws sts get-caller-identity >> /var/log/role-check.log
  EOF
  )
 
  # Instance tags
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "lt-ec2-instance"
      Environment = "dev"
      LaunchedBy  = "launch-template"
    }
  }
 
  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "lt-ec2-root-volume"
    }
  }
 
  tags = {
    Name = "custom-launch-template"
  }
}
 
# ─────────────────────────────────────────
# EC2 INSTANCE — launched from template
# ─────────────────────────────────────────
resource "aws_instance" "lt_ec2" {
  launch_template {
    id      = aws_launch_template.custom_lt.id
    version = "$Latest"   # Always use latest version of the template
  }
 
  tags = {
    Name = "lt-ec2"
  }
}
 
# ─────────────────────────────────────────
# ELASTIC IP — associated with the instance
# ─────────────────────────────────────────
resource "aws_eip" "ec2_eip" {
  instance = aws_instance.lt_ec2.id
  domain   = "vpc"
 
  tags = {
    Name = "ec2-elastic-ip"
  }
 
  depends_on = [aws_internet_gateway.igw]
}
 
# ─────────────────────────────────────────
# OUTPUTS
# ─────────────────────────────────────────
output "lt_ec2_elastic_ip" {
  description = "Elastic IP associated with the launch template EC2"
  value       = aws_eip.ec2_eip.public_ip
}
 
output "lt_ec2_instance_id" {
  description = "Instance ID of the LT-launched EC2"
  value       = aws_instance.lt_ec2.id
}
 
output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.custom_lt.id
}
 
output "iam_role_arn" {
  description = "ARN of the IAM role attached to EC2"
  value       = aws_iam_role.ec2_role.arn
}
```
 
### How to Create a New Version of the Launch Template
 
If you want to update the AMI and create a new template version (without destroying the old one):
 
```hcl
resource "aws_launch_template" "custom_lt" {
  # ... same config ...
  image_id = "ami-new-ami-id-here"  # Update AMI
}
# Terraform will create a new version automatically
```
 
Or via AWS CLI:
```bash
aws ec2 create-launch-template-version \
  --launch-template-id lt-xxxxxxxxxx \
  --source-version 1 \
  --launch-template-data '{"ImageId":"ami-new-id"}'
```
 
---

## Expectation 3: Differentiate EBS, EFS, and Instance Store — Complete Answer
 
### Persistence Model
 
| Storage | What happens when instance stops? | What happens when instance terminates? |
|---|---|---|
| **EBS** | Data **persists** (volume detaches logically) | Data **persists** UNLESS "Delete on Termination" is checked |
| **EFS** | Data **persists** (it's a separate service) | Data **persists** (completely independent of EC2) |
| **Instance Store** | Data is **lost immediately** | Data is **lost immediately** |
 
**Why Instance Store loses data on stop:** The physical disk is on the host machine. When the instance stops, AWS may move it to a different physical host on restart. The original host's disks are not yours.
 
---
 
### Multi-Instance Attachment
 
| Storage | Can multiple EC2s access simultaneously? |
|---|---|
| **EBS** | No (one instance at a time) — exception: io1/io2 **Multi-Attach** (same AZ only, up to 16 instances, specialized use) |
| **EFS** | **Yes** — designed for this; thousands of instances across multiple AZs can mount it concurrently |
| **Instance Store** | No — physically tied to one host |
 
---
 
### Use Cases and Performance
 
**EBS — use when:**
- You need a persistent disk for a single EC2 instance
- Running a database (MySQL, PostgreSQL) on EC2
- Boot volume (root disk) — always EBS
- You need snapshots for backup and disaster recovery
- Performance: predictable, consistent IOPS (up to 256,000 with io2 Block Express)
**EFS — use when:**
- Multiple EC2 instances need to share the same files
- Running a CMS (WordPress) across multiple servers that need a shared `wp-content/uploads`
- Shared home directories in a multi-user Linux environment
- CI/CD pipelines where multiple agents need the same build artifacts
- Performance: scales automatically, but higher latency than EBS (it's a network file system)
**Instance Store — use when:**
- You need the absolute fastest disk I/O possible (local NVMe, millions of IOPS)
- The data is temporary by nature — buffers, caches, scratch space
- You're running a distributed system where data is replicated across nodes (Kafka, Cassandra, HDFS) — if one node's disk dies, the data exists on other nodes
- Processing large datasets where you don't need to keep the intermediate results
---
 
### When NOT to Use Each
 
**Do NOT use EBS when:**
- Multiple instances need to access the same data simultaneously — use EFS instead
- You need extremely low latency local I/O — use Instance Store instead
- The data is truly temporary — you're paying for EBS unnecessarily
**Do NOT use EFS when:**
- Only one instance needs the storage — EFS is more expensive per GB than EBS
- You need a boot volume — EFS cannot be used as a root volume
- You need Windows-compatible shared storage — EFS is NFS (Linux only); use FSx for Windows instead
- You need extremely high, predictable IOPS — EBS io2 is better for that
**Do NOT use Instance Store when:**
- The data must persist across reboots or instance stops
- You're running a primary database without replication elsewhere
- You need to back up or snapshot the data
- You're unsure if the workload is fault-tolerant — if you're unsure, use EBS
---
 
### Decision Guide
 
```
Is the data temporary/cache/scratch?
  YES → Instance Store (if instance type supports it) or EFS IA
  NO  → Persistent storage needed
 
Do multiple instances need the SAME data simultaneously?
  YES → EFS
  NO  → EBS
 
Do you need maximum IOPS / lowest latency?
  YES → Instance Store (if temporary) or EBS io2 (if persistent)
  NO  → EBS gp3 (good default for most workloads)
```
 
---
 
### Quick Real-World Mappings
 
| Workload | Recommended Storage | Reason |
|---|---|---|
| MySQL/PostgreSQL database | EBS gp3 or io2 | Persistent, high IOPS, single instance |
| WordPress across 3 web servers | EFS | Shared `uploads` folder |
| Redis cache (replicated cluster) | Instance Store | Ephemeral, ultra-fast, data is in-memory anyway |
| EC2 boot volume | EBS | Required — only option |
| ML training scratch space | Instance Store or EBS gp3 | Scratch: Instance Store; Checkpoints: EBS |
| Shared config files across team's EC2s | EFS | Multi-instance read/write |
| Video rendering intermediate frames | Instance Store | Temporary, high throughput needed |
| Kafka broker (replicated topic) | Instance Store or EBS | Replicated: Instance Store; Durable: EBS |
 
---