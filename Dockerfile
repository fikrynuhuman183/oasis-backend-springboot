# Use OpenJDK 17 as the base image
FROM openjdk:17-jdk-slim

# Set working directory
WORKDIR /app

# Install Maven
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

# Copy Maven configuration files
COPY pom.xml .
COPY mvnw .
COPY mvnw.cmd .
COPY .mvn .mvn

# Download dependencies (this layer will be cached unless pom.xml changes)
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Create directories for file storage
RUN mkdir -p /app/Storage/images && \
    mkdir -p /app/Storage/Reports && \
    mkdir -p /app/Storage/ConsentForms

# Copy any existing storage files (optional - if you want to include them in the image)
COPY src/main/Storage/ ./Storage/

# Expose the port that Spring Boot runs on
EXPOSE 8080

# Set environment variables for file storage paths
ENV uploadDir=/app/Storage/images
ENV reportUploadDir=/app/Storage/Reports
ENV consentFormUploadDir=/app/Storage/ConsentForms

# Run the application
CMD ["java", "-jar", "target/ocrspring-0.0.1-SNAPSHOT.jar"]