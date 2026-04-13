# Multi-stage Dockerfile for a java based application
# This Dockerfile is written to optimize build times and enhance security by separating the build environment from the runtime environment.

# STAGE 1: Build Stage
# Purpose: Pull dependencies, compile the source code, and package the JAR.

# Use a Maven image that includes the JDK to compile the code
FROM maven:3.9-eclipse-temurin-17-alpine AS builder

# Set the working directory for the build process
WORKDIR /build

# COPY STEP 1: Copy only the pom.xml first. Why? Docker caches layers. If your dependencies haven't changed, 
# Docker will use the cached layer for the next step, speeding up builds significantly.
COPY pom.xml .

# Download dependencies offline
RUN mvn dependency:go-offline -B

# COPY STEP 2: Copy the actual source code.
COPY src ./src

# Build the application. 
# We use -DskipTests here because unit tests should be handled earlier in the CI pipeline, not during the image build.
RUN mvn clean package -DskipTests -B


# STAGE 2: Production Stage
# Purpose: Run the compiled application in a secure, minimal environment.

# We switch back to the minimal JRE image
FROM eclipse-temurin:17-jre-alpine

# DevSecOps Best Practice: Never run containers as 'root'
# We create a specific system group and user for our application
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set the working directory inside the final container
WORKDIR /app

# The Magic Step: Copy ONLY the final JAR file from the 'builder' stage above.
# The source code, Maven, and JDK are left behind and destroyed.
COPY --from=builder /build/target/*.jar app.jar

# Enforce security by switching from root to the new restricted user
USER appuser:appgroup

# Document the port the application listens on
EXPOSE 8080

# Command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]