# Shell Scripting

## 1. Numeric Comparison Operators

| Operator | Description |
|----------|------------|
| `-eq`    | Equal to |
| `-ne`    | Not equal to |
| `-gt`    | Greater than |
| `-lt`    | Less than |
| `-ge`    | Greater than or equal to |
| `-le`    | Less than or equal to |

### Example

```bash
#!/bin/bash (#! - Shebang/hashbang)

a=10
b=20

if [ $a -eq $b ]; then
    echo "a is equal to b"
fi

if [ $a -ne $b ]; then
    echo "a is not equal to b"
fi

if [ $a -gt $b ]; then
    echo "a is greater than b"
else
    echo "a is not greater than b"
fi

if [ $a -lt $b ]; then
    echo "a is less than b"
fi

if [ $a -ge 10 ]; then
    echo "a is greater than or equal to 10"
fi

if [ $b -le 20 ]; then
    echo "b is less than or equal to 20"
fi
```

---

## 2. String Comparison Operators

| Operator | Description          |
|----------|----------------------|
| `=`      | Equal                |
| `!=`     | Not equal            |
| `-z`     | String is empty      |
| `-n`     | String is not empty  |

### Example

```bash
#!/bin/bash

str1="hello"
str2="world"
empty=""

if [ "$str1" = "$str2" ]; then
    echo "Strings are equal"
else
    echo "Strings are not equal"
fi

if [ "$str1" != "$str2" ]; then
    echo "Strings are different"
fi

if [ -z "$empty" ]; then
    echo "String is empty"
fi

if [ -n "$str1" ]; then
    echo "String is not empty"
fi
```

---

## 3. String Case Manipulation

| Syntax        | Description |
|---------------|------------|
| `${VAR^^}`    | Convert entire string to uppercase |
| `${VAR,,}`    | Convert entire string to lowercase |
| `${VAR^}`     | Capitalize first letter |
| `${VAR,}`     | Lowercase first letter |

### Example

```bash
#!/bin/bash

VAR="hello world"

echo "Original: $VAR"
echo "Uppercase all: ${VAR^^}"
echo "Lowercase all: ${VAR,,}"
echo "Capitalize first letter: ${VAR^}"
echo "Lowercase first letter: ${VAR,}"
```

---

## 4. Logical Operators

| Operator | Description |
|----------|-------------|
| `-a`     | AND         |
| `-o`     | OR          |
| `!`      | NOT         |

### Example (Using `[ ]`)

```bash
#!/bin/bash

read -p "Enter your age: " age
read -p "Do you have ID? (yes/no): " id

if [ $age -ge 18 -a "$id" = "yes" ]; then
    echo "Access granted (Adult with ID)"

elif [ $age -lt 18 -o "$id" = "no" ]; then
    echo "Access denied (Minor OR No ID)"
fi

# Using NOT
if [ ! "$id" = "yes" ]; then
    echo "Warning: ID is mandatory"
fi
```

### Example (Using `[[ ]]` - Recommended)

```bash
#!/bin/bash

if [[ $age -ge 18 && "$id" == "yes" ]]; then
    echo "Access granted"
fi

if [[ $age -lt 18 || "$id" == "no" ]]; then
    echo "Access denied"
fi

if [[ "$id" != "yes" ]]; then
    echo "ID is mandatory"
fi
```

---

## 5. Loops

### 5.1 For Loop

```bash
for i in 1 2 3 4
do
  echo $i
done
```

### 5.2 While Loop

```bash
i=1
while [ $i -le 5 ]
do
  echo $i
  ((i++))
done
```

### 5.3 Until Loop

```bash
i=1
until [ $i -gt 5 ]
do
  echo $i
  ((i++))
done
```

---

## 6. File Test Operators

| Operator     | Description |
|--------------|-------------|
| `-e file`    | File exists |
| `-f file`    | Regular file |
| `-d file`    | Directory exists |
| `-r file`    | Readable |
| `-w file`    | Writable |
| `-x file`    | Executable |
| `-s file`    | File is not empty |

### Example

```bash
#!/bin/bash

file="test.txt"
dir="sample_dir"

# Check if file exists
if [ -e "$file" ]; then
    echo "$file exists"
fi

# Check if it's a regular file
if [ -f "$file" ]; then
    echo "$file is a regular file"
fi

# Check if it's a directory
if [ -d "$dir" ]; then
    echo "$dir is a directory"
fi

# Check permissions
if [ -r "$file" ]; then
    echo "$file is readable"
fi

if [ -w "$file" ]; then
    echo "$file is writable"
fi

if [ -x "$file" ]; then
    echo "$file is executable"
fi

# Check if file is not empty
if [ -s "$file" ]; then
    echo "$file is not empty"
else
    echo "$file is empty or does not exist"
fi
```
---

## 7. Practical Tasks (Shell Scripting)

### 7.1 Count Lines, Words, Characters

```bash
#!/bin/bash

file=$1

echo "Lines: $(wc -l < $file)"
echo "Words: $(wc -w < $file)"
echo "Characters: $(wc -c < $file)"
```

---

### 7.2 Process Log File

```bash
#!/bin/bash

logfile="app.log"

echo "ERROR logs:"
grep "ERROR" $logfile

echo "WARNING logs:"
grep "WARNING" $logfile

echo "Logs from today:"
grep "$(date '+%Y-%m-%d')" $logfile
```

---

### 7.3 System Information Script

```bash
#!/bin/bash

echo "Kernel Version:"
uname -r

echo "Memory Usage:"
free -h

echo "Running Processes:"
ps aux | head -10

echo "Installed Packages (Ubuntu):"
dpkg -l | head -10
```

---

## 8. Supervisor (Process Management Tool)

### 8.1 Installation

```bash
sudo apt update
sudo apt install supervisor
supervisord --version
```

---

### 8.2 Create a Dummy Script

Create a simple script that prints the date every second.

```bash
nano ~/ticktock.sh
```

#### Script Content

```bash
#!/bin/bash

while true; do
  echo "Tick: $(date)"
  sleep 1
done
```

---

### 8.3 Create Supervisor Configuration

Supervisor configuration files are stored in:

```
/etc/supervisor/conf.d/
```

```bash
sudo nano /etc/supervisor/conf.d/ticktock.conf
```

#### Configuration Content

```ini
[program:ticktock]
command=/home/user/super/ticktock.sh
autostart=true
autorestart=true
stderr_logfile=/var/log/ticktock.err.log
stdout_logfile=/var/log/ticktock.out.log
```

---

### 8.4 Activate and Manage Supervisor

```bash
# Reload configuration
sudo supervisorctl reread
sudo supervisorctl update

# Check status
sudo supervisorctl status

# View logs
sudo tail -f /var/log/ticktock.out.log

# Kill process manually
sudo kill -9 <PID>

# Open interactive control
sudo supervisorctl
```

---

### 8.5 Key Notes

- `reread` → Detects new or changed configuration files
- `update` → Applies changes and starts/stops programs
- `autorestart=true` → Ensures process restarts on failure
- Logs help in debugging (`stdout` and `stderr`)

---

---

## 9. Supervisor (Advanced Usage)

### 9.1 Inside `supervisorctl`

```bash
# Start process
start ticktock

# Stop process
stop ticktock

# Restart process
restart ticktock

# View status
status

# View logs (live)
tail -f ticktock
```

### Example Commands

```bash
sudo supervisorctl start test
sudo supervisorctl stop test
sudo supervisorctl restart test
sudo supervisorctl status
```

---

### 9.2 Logs

```bash
cat /var/log/test.out.log
cat /var/log/test.err.log
```

---

## 10. Monit (Monitoring Tool)

### 10.1 Installation

```bash
sudo apt install monit -y
```

---

### 10.2 Common Commands

| Command | Description |
|--------|------------|
| `dpkg -l \| grep monit` | Check if Monit is installed |
| `monit --version` | Check version |
| `monit -V` | Detailed version info |
| `sudo systemctl status monit` | Check service status |
| `sudo systemctl enable monit` | Enable at startup |
| `sudo systemctl disable monit` | Disable at startup |
| `sudo monit reload` | Reload Monit configuration |
| `sudo systemctl reload monit` | Reload service |
| `sudo monit status` | Show monitoring status |

---

### 10.3 Monit Configuration Directory

```bash
cd /etc/monit
```

#### Important Files

- `monitrc` → Main configuration file  
- `conf-available/` → Available configs  
- `conf-enabled/` → Enabled configs  
- `conf.d/` → Additional configs  
- `templates/` → Template configs  

```bash
sudo cat /etc/monit/monitrc
```

---

### 10.4 Enable Web Interface

Default credentials:

```
Username: admin
Password: monit
```

#### Configuration Snippet

```bash
set httpd port 2812 and
    use address 0.0.0.0
    allow 0.0.0.0/0
    allow admin:monit
```

---

### 10.5 Access Monit UI

```bash
http://localhost:2812
```

If using WSL:

```bash
hostname -I
```

Then access:

```bash
http://<YOUR_WSL_IP>:2812
```

---

## 11. Loops (Detailed)

### 11.1 For Loop Syntax

```bash
for variable in list
do
  commands
done
```

---

### 11.2 Example 1: Print Numbers

```bash
#!/bin/bash

for i in 1 2 3 4 5
do
  echo "Number: $i"
done
```

---

### 11.3 Example 2: Range Loop

```bash
#!/bin/bash

for i in {1..5}
do
  echo "Count: $i"
done
```

---

### 11.4 Example 3: Loop Through Files

```bash
#!/bin/bash

for file in *.log
do
  echo "Processing $file"
done
```

---
---

## 12. While Loop

### 12.1 Syntax

```bash
while condition
do
  commands
done
```

---

### 12.2 Example 1: Counter

```bash
#!/bin/bash

i=1

while [ $i -le 5 ]
do
  echo "Value: $i"
  ((i++))
done
```

---

### 12.3 Example 2: Read File Line by Line

```bash
#!/bin/bash

while read line
do
  echo "$line"
done < file.txt
```

---

## 13. Until Loop

### 13.1 Syntax

```bash
until condition
do
  commands
done
```

---

### 13.2 Example

```bash
#!/bin/bash

i=1

until [ $i -gt 5 ]
do
  echo "Value: $i"
  ((i++))
done
```

---

## 14. Loop Control Statements

### 14.1 `break` (Stop Loop)

```bash
for i in {1..10}
do
  if [ $i -eq 5 ]; then
    break
  fi
  echo $i
done
```

---

### 14.2 `continue` (Skip Iteration)

```bash
for i in {1..5}
do
  if [ $i -eq 3 ]; then
    continue
  fi
  echo $i
done
```

---

## 15. Conditional Statements

### 15.1 If Statement

```bash
if [ condition ]
then
  commands
fi
```

---

### 15.2 Example

```bash
#!/bin/bash

num=10

if [ $num -gt 5 ]
then
  echo "Number is greater than 5"
fi
```

---
---

## 16. Conditional Statements (Advanced)

### 16.1 If-Else Statement

```bash
#!/bin/bash

num=3

if [ $num -gt 5 ]
then
  echo "Greater"
else
  echo "Smaller"
fi
```

---

### 16.2 If-Elif-Else Statement

```bash
#!/bin/bash

num=5

if [ $num -gt 5 ]
then
  echo "Greater"
elif [ $num -eq 5 ]
then
  echo "Equal"
else
  echo "Smaller"
fi
```

---

## 17. Comparison Operators (Consolidated)

### 17.1 Numeric Operators

| Operator | Meaning |
|----------|--------|
| `-eq`    | Equal |
| `-ne`    | Not equal |
| `-gt`    | Greater than |
| `-lt`    | Less than |
| `-ge`    | Greater than or equal |
| `-le`    | Less than or equal |

---

### 17.2 String Operators

| Operator | Meaning |
|----------|--------|
| `=`      | Equal |
| `!=`     | Not equal |
| `-z`     | Empty string |
| `-n`     | Not empty |

---

### 17.3 File Conditions

| Condition | Meaning |
|-----------|--------|
| `-f`      | File exists (regular file) |
| `-d`      | Directory exists |
| `-r`      | Readable |
| `-w`      | Writable |
| `-x`      | Executable |

---

## 18. Practical Examples

### 18.1 Check File Exists

```bash
#!/bin/bash

if [ -f "test.txt" ]
then
  echo "File exists"
else
  echo "File not found"
fi
```

---

### 18.2 Check Service Running

```bash
#!/bin/bash

if pgrep nginx > /dev/null
then
  echo "Nginx is running"
else
  echo "Nginx is stopped"
fi
```

---

### 18.3 Disk Usage Alert

```bash
#!/bin/bash

usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

if [ $usage -gt 80 ]
then
  echo "Disk usage is high: $usage%"
else
  echo "Disk is normal"
fi
```

---
---

## 19. Logical Operators (Advanced Usage)

### 19.1 AND (`&&`)

```bash
if [ $a -gt 5 ] && [ $b -lt 10 ]
```

---

### 19.2 OR (`||`)

```bash
if [ $a -gt 5 ] || [ $b -lt 10 ]
```

---

### 19.3 NOT (`!`)

```bash
if [ ! -f file.txt ]
```

---

## 20. Nested If Statement

```bash
#!/bin/bash

num=10

if [ $num -gt 5 ]
then
  if [ $num -lt 20 ]
  then
    echo "Between 5 and 20"
  fi
fi
```

---

## 21. Short Form (One-Line If)

```bash
[ -f file.txt ] && echo "Exists" || echo "Not exists"
```

---

## 22. Essential Linux Commands for Scripting

### 22.1 `grep` → Search Text

```bash
grep "ERROR" app.log
grep -c "ERROR" app.log
grep -i "error" app.log
grep -n "ERROR" app.log
```

---

### 22.2 `awk` → Data Processing

```bash
df -h | awk '{print $1, $5}'
df -h | awk 'NR==2 {print $5}'
```

---

### 22.3 `sed` → Stream Editor

```bash
sed 's/error/ERROR/g' file.txt
echo "disk=80%" | sed 's/%//'
```

---

### 22.4 `cut` → Extract Columns

```bash
cut -d':' -f1 /etc/passwd
```

---

### 22.5 `sort` → Sort Data

```bash
sort file.txt
sort -n numbers.txt
```

---

### 22.6 `uniq` → Remove Duplicates

```bash
sort file.txt | uniq
sort file.txt | uniq -c
```

---

### 22.7 `wc` → Count Data

```bash
wc -l file.txt   # lines
wc -w file.txt   # words
wc -c file.txt   # characters
```

---

### 22.8 `head` & `tail`

```bash
head file.txt
tail file.txt
tail -f app.log
```

---

### 22.9 `tr` → Translate Characters

```bash
echo "hello" | tr 'a-z' 'A-Z'
```

---

## 23. System Design Note (Supervisor + Monit)

```
Your Application (Python / Node / Script)
        ↓
Supervisor (start, stop, restart)
        ↓
Monit (health checks, CPU, memory, alerts)
```

---

### Key Insight

- **Supervisor** → Process control (lifecycle management)  
- **Monit** → Monitoring + alerting (health checks)  
- Together → Build a **self-healing system**

---