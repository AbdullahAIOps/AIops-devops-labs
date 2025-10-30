# Lab 1: Exploring Container Orchestration

### Overview
This lab was focused on understanding what happens when we try to manage multiple containers manually without using an orchestration tool like Kubernetes or Docker Swarm.  
I worked through several practical exercises to deploy, scale, and monitor multiple web applications running in Docker containers — all managed manually — to see where the process starts to break down.

---

### Objectives
By the end of this lab, I was able to:

- Deploy multiple containerized web applications manually using Docker.  
- Identify and troubleshoot port conflicts and resource usage issues.  
- Simulate scaling and container failure scenarios without orchestration.  
- Understand the challenges of manual recovery and load balancing.  
- Compare manual container management to orchestrated solutions.

---

### Environment
The lab environment was a pre-configured Ubuntu 20.04 instance with Docker already installed.  
All exercises were done in a Linux terminal using Docker CLI commands.  

---

### What I Did

#### **1. Verified Docker and Set Up Project Structure**
I started by checking that Docker was properly installed and running.  
Then I created a simple working directory structure for two web applications (`app1` and `app2`).

#### **2. Deployed Two Web Applications Manually**
- I pulled the official `nginx:latest` image and deployed it as my first web app running on port **8080**.  
- After customizing its `index.html`, I deployed a second Nginx container.  
- Attempting to use the same port caused a **port binding error**, which showed the first major limitation of manual container management.  
- I fixed it by running the second app on **port 8081**, with a unique custom web page.

#### **3. Explored Resource and Performance Management**
I ran multiple containers and used `docker stats` to observe CPU and memory usage.  
Manually assigning resource limits (like `--memory=128m` and `--cpus=0.5`) made it clear how tedious it can be to manage performance and resources by hand.  

#### **4. Simulated Scaling and Failures**
I wrote simple bash scripts to:
- Deploy five instances of the same app manually (simulating a scaled environment).  
- Test all instances one by one using curl.  
- Stop and restart containers to simulate failures and recover them manually.

This exercise showed how time-consuming scaling and recovery can be without automation.

#### **5. Set Up a Manual Load Balancer**
To distribute traffic between my manually scaled containers, I configured an Nginx load balancer using a custom upstream block.  
Testing the setup worked, but it highlighted how much manual effort it takes to configure and maintain load balancing when scaling containers dynamically.

#### **6. Documented and Analyzed Challenges**
I summarized the main problems encountered during the lab:
- Port conflicts  
- Resource contention  
- Manual scaling and recovery  
- Lack of built-in load balancing and service discovery  
- Inconsistent configuration management  

#### **7. Compared Manual vs. Orchestrated Management**
I created a short comparison showing how orchestration platforms like Kubernetes solve these problems:
- Automatic port and resource management  
- Self-healing and auto-scaling  
- Built-in load balancing and DNS-based service discovery  
- Centralized configuration with ConfigMaps and Secrets  

Finally, I cleaned up all running containers and Nginx configurations manually — another reminder of how much easier this would be with orchestration tools.

---

### Key Takeaways
- Managing multiple containers manually quickly becomes complex and error-prone.  
- Scaling, failure recovery, and load balancing require constant attention and manual effort.  
- Container orchestration tools like **Kubernetes** and **Docker Swarm** automate these tasks, ensuring stability, scalability, and high availability.  
- The challenges faced in this lab clearly demonstrate why orchestration is essential for production environments.

---

### Reflection
This lab gave me hands-on insight into the operational problems that orchestration platforms are built to solve.  
By manually deploying, scaling, and maintaining containers, I developed a stronger appreciation for tools like Kubernetes that handle these challenges automatically.

---

**Next Step:** In the next lab, I’ll start using Kubernetes to automate everything I did manually here — from deployment and scaling to self-healing and load balancing.
