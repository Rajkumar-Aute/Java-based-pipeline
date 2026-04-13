name: Java CI Enterprise Pipeline

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  # job 1: Continuous Integration (Build, Test and Security)
  build-test-and-secure:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout Code
      uses: actions/checkout@v4

    - name: Set up JDK 17
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
        cache: 'maven'

    - name: Build with Maven
      run: mvn -B package --file pom.xml

    - name: Run Unit Tests
      run: mvn test

    - name: Upload Build Artifact
      uses: actions/upload-artifact@v4
      with:
        name: java-app-package
        path: target/*.jar

  # JOB 2: Continuous Delivery (Containerization & Scanning)
  dockerize:
    needs: build-test-and-secure
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout Code
      uses: actions/checkout@v4
    
    - name: Download Artifact
      uses: actions/download-artifact@v4
      with:
        name: java-app-package
        path: target/

    # Step 2.2: Build the image locally first (so we can scan it)
    - name: Build Docker Image
      run: |
        docker build -t rajkumaraute/java-base-app:${{ github.sha }} .

    # Step 2.3: Scan the Docker Image using Trivy (DevSecOps best practice)
    # This will fail the pipeline if "CRITICAL" vulnerabilities are found.
    - name: Run Trivy Vulnerability Scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: 'rajkumaraute/java-base-app:${{ github.sha }}'
        format: 'table'
        exit-code: '1' # This fails the build if vulnerabilities are found
        ignore-unfixed: true
        vuln-type: 'os,library'
        severity: 'CRITICAL,HIGH'

    # Step 2.4: Authenticate and Push (Only if scan passes)
    - name: Login and Push to Docker Hub
      run: |
        echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin
        
        # Push both tags
        docker push rajkumaraute/java-base-app:${{ github.sha }}
        docker push rajkumaraute/java-base-app:${{ github.run_number }}