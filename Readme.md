# Dockerized Spark Cluster Setup

This guide will help you set up a Dockerized Spark cluster with custom web UI ports. This cluster consists of a Spark master and a Spark worker node.

## Prerequisites

Before you begin, make sure you have the following installed:

- Docker
- Docker Compose

## Step 1: Create a Dockerfile

Create a `Dockerfile` to define the Docker image for your Spark cluster. Use the following content:

```Dockerfile
# Use the official openjdk image with Java 8
FROM openjdk:8-jre-slim-buster

# Set non-interactive mode for faster installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies (Python, etc.)
# Define Spark version (3.3.1)
# Set Spark home environment variable
# Define the Spark download URL for version 3.3.1
# Download and install Spark
# Set environment variables for Spark (including custom web UI ports)
# Create log directories and set up symlinks
# Copy the start-spark.sh script into the container
# Make the script executable
# Expose Spark UI ports
# Start Spark using the start-spark.sh script

# Install system dependencies
RUN apt-get update && apt-get install -y curl vim wget software-properties-common ssh net-tools ca-certificates python3 python3-pip python3-numpy python3-matplotlib python3-scipy python3-pandas python3-simpy && \
    update-alternatives --install "/usr/bin/python" "python" "$(which python3)" 1

# Define Spark version (3.3.1)
ENV SPARK_VERSION=3.3.1

# Set Spark home environment variable
ENV SPARK_HOME=/opt/spark

# Define the Spark download URL for version 3.3.1
ENV SPARK_URL=https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz

# Download and install Spark
RUN wget -O apache-spark.tgz "$SPARK_URL" \
    && mkdir -p /opt/spark \
    && tar -xf apache-spark.tgz -C /opt/spark --strip-components=1 \
    && rm apache-spark.tgz

# Set environment variables for Spark
ENV SPARK_MASTER_PORT=7077 \
    SPARK_MASTER_WEBUI_PORT=8082 \
    SPARK_LOG_DIR=/opt/spark/logs \
    SPARK_MASTER_LOG=/opt/spark/logs/spark-master.out \
    SPARK_WORKER_LOG=/opt/spark/logs/spark-worker.out \
    SPARK_WORKER_WEBUI_PORT=8083 \
    SPARK_WORKER_PORT=7000 \
    SPARK_MASTER="spark://spark-master:7077" \
    SPARK_WORKLOAD="master"

# Create log directories and set up symlinks
RUN mkdir -p $SPARK_LOG_DIR && \
    touch $SPARK_MASTER_LOG && \
    touch $SPARK_WORKER_LOG && \
    ln -sf /dev/stdout $SPARK_MASTER_LOG && \
    ln -sf /dev/stdout $SPARK_WORKER_LOG

# Copy the start-spark.sh script into the container
COPY start-spark.sh /

# Make the script executable
RUN chmod +x /start-spark.sh

# Expose Spark UI ports
EXPOSE 8080 7077 8083 7000

# Start Spark using the start-spark.sh script
CMD ["/bin/bash", "/start-spark.sh"]
```

## Step 2: Create a start-spark.sh Script
Create a start-spark.sh script that initializes the Spark cluster. Use the following content:

```start-spark.sh
#!/bin/bash

# Source the Spark environment
. "$SPARK_HOME/sbin/spark-config.sh"
. "$SPARK_HOME/bin/load-spark-env.sh"

# Determine the Spark workload type
if [ "$SPARK_WORKLOAD" == "master" ]; then
    # Start Spark master
elif [ "$SPARK_WORKLOAD" == "worker" ]; then
    # Start Spark worker
elif [ "$SPARK_WORKLOAD" == "submit" ]; then
    echo "SPARK SUBMIT"
else
    echo "Undefined Workload Type $SPARK_WORKLOAD, must specify: master, worker, submit"
fi

# Keep the container running
tail -f /dev/null
```

## Step 3: Build Docker Images
Run the following command to build Docker images:

```commandline
docker-compose build
```

## Step 4: Create a Docker Compose Configuration (docker-compose.yml)
Create a docker-compose.yml file to define the services and configuration for the Spark cluster. Use the following content:

```docker-compose.yml
version: "3.3"
services:
  spark-master:
    build: .
    container_name: docker-spark
    ports:
      - "8082:8082"  # Map the new Master web UI port to host
      - "7077:7077"
    volumes:
      - ./apps:/opt/spark-apps
      - ./data:/opt/spark-data
    environment:
      - SPARK_LOCAL_IP=spark-master
      - SPARK_WORKLOAD=master
    command: ["/bin/bash", "/start-spark.sh"]

  spark-worker:
    build: .
    container_name: hduser-spark-worker
    ports:
    - "8083:8083"

    environment:
      - SPARK_LOCAL_IP=spark-worker
      - SPARK_WORKLOAD=worker

    command: ["/bin/bash", "/start-spark.sh"]
```

## Step 5: Run Docker Compose
Start the Spark cluster using Docker Compose:

```commandline
docker-compose up -d
```

## Step 6: Verify Docker Containers
List the Docker images and running containers to verify the setup:

```
# List Docker images 
  docker images

# List running Docker containers
  docker ps
```

## Step 7: Access Spark Web UIs
You can access the Spark Master and Worker Web UIs in your web browser:

Spark Master Web UI: http://your_server_ip:8082
Spark Worker Web UI: http://your_server_ip:8083
Replace your_server_ip with the IP address or hostname of your host machine.

EXAMPLE:-
```commandline
http://localhost:8082/
```
