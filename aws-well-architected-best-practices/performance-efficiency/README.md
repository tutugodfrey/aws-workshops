# Performance Efficiency

## Objective

- Create target tracking scaling policies for an Amazon EC2 Auto Scaling group
- Create an Amazon CloudWatch dashboard
- Perform a stress test to validate the scaling policy


Stress Test comnand. Ran with system manager AWS-RunShellScript, to stress test autoscaling group

```bash
#!/bin/bash
sudo stress --cpu 8 --vm-bytes $(awk '/MemAvailable/{printf "%d\n", $2 * 0.9;}' < /proc/meminfo)k --vm-keep -m 1 --timeout 300s
```
