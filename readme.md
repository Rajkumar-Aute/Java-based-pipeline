# Enterprise Java DevSecOps Pipeline

![Java](https://img.shields.io/badge/Java-17-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2-green)
![Docker](https://img.shields.io/badge/Docker-Enabled-blue)
![Trivy](https://img.shields.io/badge/Security-Trivy%20Scan-yellow)

This repository contains a **Java Spring Boot Application** integrated with a comprehensive **GitHub Actions DevSecOps Pipeline**. The pipeline automates the entire lifecycle from code compilation to secure container distribution.

## 🚀 Application Overview
The application is a Spring Boot web service that serves a landing page displaying:
- **Welcome Message:** Personalized for `DevSecOpsGuru.in`.
- **Dynamic Data:** Current system date and time.
- **Traceability:** The specific Hostname/Pod ID of the machine serving the request.

## 🏗 Project Architecture
The repository is structured as follows:
- `.github/workflows/`: Contains the GitHub Actions YAML pipeline.
- `src/main/`: Java source code and HTML templates (Thymeleaf).
- `pom.xml`: Maven configuration and dependency management.
- `Dockerfile`: non-root, minimal JRE runtime image.

## 🛠 CI/CD Pipeline Stages

### 1. Build & Test (`build-test-and-secure`)
- **Environment:** Ubuntu-latest with JDK 17 (Temurin).
- **Caching:** Maven dependency caching is enabled to reduce build times by up to 60%.
- **Validation:** Runs `mvn package` and `mvn test` to ensure code quality and functional correctness.
- **Artifact:** Uploads the compiled `.jar` file to GitHub storage.

### 2. Containerization & Security (`dockerize`)
- **Immutability:** Downloads the exact `.jar` from the previous stage.
- **Docker Build:** Creates a Docker image using the GitHub SHA and Run Number as tags.
- **Container Scan (Trivy):**
    - Scans the OS layers and Java libraries for vulnerabilities.
    - **Policy:** The pipeline will fail if any `CRITICAL` or `HIGH` vulnerabilities are detected.
- **Distribution:** Authenticates with Docker Hub and pushes the secure image to `<Docker-Hub-Registry>/java-base-app`.

## 🔑 Prerequisites & Setup

### Local Development
To run this application on your machine:
1. Ensure `JAVA_HOME` is set to JDK 17.
2. Run `mvn clean package`.
3. Execute `java -jar target/*.jar`.
4. Access at `http://localhost:8080`.

### GitHub Secrets Configuration
To enable the pipeline, add the following secrets to your GitHub Repository (**Settings > Secrets and variables > Actions**):

| Secret Name | Description |
| :--- | :--- |
| `DOCKER_USERNAME` | Your Docker Hub ID (e.g., `rajkumaraute`) |
| `DOCKER_PASSWORD` | Docker Hub Personal Access Token (PAT) |
| `SNYK_TOKEN` | (Optional) API key for Snyk SCA scanning |
| `SONAR_TOKEN` | (Optional) API key for SonarCloud SAST |

## 🛡 Security Best Practices Implemented
- **Shift-Left Security:** Automated testing and scanning on every Pull Request.
- **Minimal Runtime:** Uses `eclipse-temurin:17-jre-alpine` to reduce the attack surface.
- **Non-Root Execution:** The Docker container runs as a restricted `appuser`.
- **Traceability:** Every image is tagged with the unique Git Commit SHA.
- **Binary Integrity:** The same JAR file that passes tests is the one packaged into Docker.

---
*Maintained by [Rajkumar Aute](https://devsecopsguru.in)*