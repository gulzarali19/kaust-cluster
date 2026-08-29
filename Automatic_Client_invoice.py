import re
from datetime import datetime

# CONFIGURATION
LOG_FILE = "/var/log/slurm/jobcomp.log"
TARGET_USER = "user01"
VCPUS_PER_NODE = 2        # c7i-flex.large node capacity
RATE_PER_CORE_HOUR = 0.15 # Your custom rate in USD

total_core_hours = 0.0
completed_jobs = 0

with open(LOG_FILE, "r") as f:
    for line in f:
        if f"UserId={TARGET_USER}" in line:
            # Extract fields
            start_str = re.search(r"StartTime=([^\s]+)", line).group(1)
            end_str = re.search(r"EndTime=([^\s]+)", line).group(1)
            node_cnt = int(re.search(r"NodeCnt=(\d+)", line).group(1))
            state = re.search(r"JobState=([^\s]+)", line).group(1)

            # Calculate duration in hours
            fmt = "%Y-%m-%dT%H:%M:%S"
            start_dt = datetime.strptime(start_str, fmt)
            end_dt = datetime.strptime(end_str, fmt)
            duration_hours = (end_dt - start_dt).total_seconds() / 3600.0

            # Core-hours calculation
            core_hours = duration_hours * node_cnt * VCPUS_PER_NODE
            total_core_hours += core_hours
            completed_jobs += 1

            print(f"Job State: {state} | Duration: {duration_hours:.2f} hrs | Nodes: {node_cnt} | Core-Hours: {core_hours:.2f}")

total_cost = total_core_hours * RATE_PER_CORE_HOUR

print("\n--- INVOICE SUMMARY ---")
print(f"User: {TARGET_USER}")
print(f"Total Jobs Logged: {completed_jobs}")
print(f"Total Core-Hours: {total_core_hours:.2f} hrs")
print(f"Total Amount Due: ${total_cost:.2f}")
