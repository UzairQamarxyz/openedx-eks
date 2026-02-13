# **Mandatory Clarifications & Enforcement Criteria**

## **OpenEdX Kubernetes Technical Assessment – Addendum**

This document serves as a **mandatory addendum** to the previously issued **OpenEdX Kubernetes Technical Assessment**.
 The requirements below **must be implemented and demonstrated**. Submissions that do not comply will be considered **incomplete**, irrespective of partial or functional deployments.

## **1. Production-Ready Definition**

For the purpose of this assessment, a **production-ready** deployment is defined as one that:

* Is **Kubernetes-native** and does not follow VM-style deployment patterns
* Has **no dependency on single-pod or in-cluster state** for critical data
* Is designed for **horizontal scaling** and **failure recovery**
* Governs all external access through **ingress and load-balancing**
* Maintains clear separation between **traffic management**, **application services**, and **data services**

Deployments that operate correctly but cannot scale, recover from failures, or tolerate pod restarts will **not** be considered production-ready.

## **2. Ingress Requirement**

### **Mandatory**

* Deployment of a Kubernetes **Ingress Controller** (Nginx preferred)
* Exposure of OpenEdX LMS and CMS **exclusively through ingress**

### **Not Permitted**

* Default Tutor **Caddy** server
* Direct exposure via **NodePort** or **LoadBalancer**
* Any routing that bypasses ingress

## **3. External Database Requirement**

All stateful services must be **external to the Kubernetes cluster** (managed services or separate instances).

| **Service** | **Purpose** |
| --- | --- |
| MySQL | Core relational data |
| Redis | Caching and task queues |
| MongoDB | Course content and modulestore |
| Search | Platform and course search (external where supported) |

In-cluster databases used to simulate production behavior are **not acceptable**.

## **4. Course Creation & Data Persistence Validation**

The deployed platform must demonstrably:

* Create courses using **OpenEdX Studio**
* Persist course structure and content in **external MongoDB**
* Retain all data following pod restarts or rescheduling

Failure to meet any of the above constitutes an **automatic failure** of this requirement.
 Reviewers may validate by inspecting MongoDB collections and restarting application pods.

## **5. Hyperscale Readiness**

Submissions must demonstrate:

* **Stateless** LMS and CMS application pods
* Properly configured **readiness and liveness probes**
* A defined scaling strategy:

**Horizontal Pod Autoscaler (HPA)** configuration, and
 Resource requests/limits aligned with scaling behavior

## **6. Mandatory Submission Artifacts**

The following **configuration files must be submitted** as part of the assessment:

* Kubernetes manifests (Deployments, Services, Ingress, HPA, ConfigMaps, Secrets etc)
* Tutor configuration files and plugin configurations
* Ingress and Nginx configuration files
* Database connection and external service configuration
* Autoscaling (HPA) configuration
* Any load-testing configuration or scripts used
* Architecture and traffic-flow diagrams

Submissions without these configuration files will be treated as **incomplete**.

## **7. Live Environment Review**

As part of the evaluation, candidates must be prepared to demonstrate their **live running environment**, including:

* Walkthrough of the running Kubernetes cluster
* Live ingress routing for LMS and CMS
* Verification of external database connections
* Course creation and data persistence validation
* **Horizontal Pod Autoscaler behavior**
* **Load testing execution** and scaling response
* Pod restarts with confirmed data integrity

If the live environment does not match the submitted documentation and configuration files, the solution will be classified as **non-production-ready**.

## **8. Evaluation Impact**

Non-compliance with any mandatory requirement may result in:

* Significant score reduction
* Disqualification from production-readiness evaluation

### **Final Note**

This assessment evaluates **platform engineering capability**, not installation success.
 Submissions are judged on **architectural judgment, scalability, reliability, and operational discipline**.ocument Title
