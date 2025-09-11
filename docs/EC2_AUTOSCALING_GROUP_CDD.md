# Context-Decision-Document (CDD)

## Overview
This document captures the rationale for choosing **EC2 + AutoScaling Group (ASG)** as the execution model for our AI agent’s Terraform tasks. The CDD pattern ensures traceability and provides a durable record of the reasoning process.

## Context
- Current setup uses a single EC2 instance on a fixed **5 hours on / 19 hours off** schedule.
- Limitations of the current approach:
  - Inefficient: instance may be idle for much of its active window.
  - Inflexible: schedule is fixed, regardless of actual workload.
  - No clear health check or completion signal from the instance to indicate when it can safely power down.
- Alternatives considered:
  - **AWS Lambda:** Too constrained for Terraform (timeout limits, environment setup overhead).
  - **ECS Fargate task:** More “serverless” but requires containerizing Terraform and re-tooling workflows.
  - **Spot EC2 with ASG:** Potential cost savings but added complexity around interruption handling.
  - **EC2 + ASG (On-Demand):** Balances flexibility and familiarity; Terraform already runs in this context.

## Decision
We will adopt the **EC2 + ASG pattern** with the following design principles:
1. **On-Demand Scaling:** ASG desired capacity will be set to `0` by default. The AI agent (or external orchestrator) will increase desired capacity to `1` when work is needed.
2. **Bootstrap & Workload:** User data will provision Terraform/Tofu and run required jobs.
3. **Self-Termination:** When tasks complete successfully, the instance will:
   - Write a “done” signal (e.g., an S3 flag, SSM parameter, or DynamoDB entry).
   - Initiate its own shutdown (`aws ec2 terminate-instances` or `shutdown -h now`).
   - ASG will detect the termination and return desired capacity to `0`.
4. **Fallback Safety:** A CloudWatch metric/alarm or lifecycle hook will ensure instances are force-stopped after a maximum runtime (to prevent cost leaks if the agent crashes).

### Why not ECS Fargate?
- Would require building and maintaining a custom Terraform container image.
- Adds orchestration complexity without providing significant benefit at this stage.
- EC2 ASG gives us more control and preserves the option to migrate later.

### Why not Spot Instances?
- Interruptions add operational risk.
- On-Demand cost is acceptable for the expected workload.

## Impact
- **Cost:** Pay only for EC2 runtime, with minimal idle waste. Less predictable but controllable by AI agent.
- **Flexibility:** AI agent can start/stop work dynamically rather than on a fixed schedule.
- **Maintainability:** Reuses familiar EC2 workflows, avoids premature complexity of containerization.
- **Reliability:** Clear health signaling and safety shutoff reduce risk of runaway costs.

## Next Steps
1. **Prototype ASG with desired capacity toggle:**  
   - Define ASG with launch template (current user data adapted).  
   - Set desired capacity to `0` by default.
2. **Implement health signal mechanism:**  
   - Decide on S3/DynamoDB/SSM for “done” flag.  
   - Add self-shutdown logic to user data.
3. **Add watchdog safety net:**  
   - CloudWatch alarm or ASG lifecycle hook to stop/terminate instances after N hours.
4. **Document runbook for AI agent:**  
   - How to increase desired capacity to `1`.  
   - How to monitor for completion signal.  
   - How to handle error conditions.

---
*Generated with the Context-Decision-Document (CDD) pattern.*
