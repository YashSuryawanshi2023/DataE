# Use the official openjdk image with Java 8
FROM openjdk:8-jre-slim-buster

# Set non-interactive mode for faster installation
ENV DEBIAN_FRONTEND=noninteractive

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