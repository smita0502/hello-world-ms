# ---------- Stage 1: Build ----------
FROM maven:3.9.4-eclipse-temurin-17 AS builder

# Set working directory inside the container
WORKDIR /app

# Copy only pom.xml first (for dependency caching)
COPY pom.xml .

# Download dependencies (this will be cached)
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application and skip tests if needed
RUN mvn clean package -DskipTests

# ---------- Stage 2: Runtime ----------
FROM eclipse-temurin:17-jre

# Create a non-root user
RUN useradd -ms /bin/bash appuser

WORKDIR /home/appuser

# Copy the fat JAR from the builder image
COPY --from=builder /app/target/*.jar app.jar

# Change ownership (security best practice)
RUN chown -R appuser:appuser .

# Switch to non-root user
USER appuser

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]