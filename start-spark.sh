#!/bin/bash

# Source the Spark environment
. "$SPARK_HOME/sbin/spark-config.sh"
. "$SPARK_HOME/bin/load-spark-env.sh"

# Determine the Spark workload type
if [ "$SPARK_WORKLOAD" == "master" ]; then
    export SPARK_MASTER_HOST=`hostname`
    "$SPARK_HOME/sbin/start-master.sh" --ip $SPARK_MASTER_HOST --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT
elif [ "$SPARK_WORKLOAD" == "worker" ]; then
    "$SPARK_HOME/sbin/start-worker.sh" $SPARK_MASTER
elif [ "$SPARK_WORKLOAD" == "submit" ]; then
    echo "SPARK SUBMIT"
else
    echo "Undefined Workload Type $SPARK_WORKLOAD, must specify: master, worker, submit"
fi

# Keep the container running
tail -f /dev/null
