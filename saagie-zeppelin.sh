#!/bin/bash

# As volumes are mounted at container startup,
# we need to grab mounted Spark conf and overwrite the default one before
# before running Zepplin
if [ -f "/usr/local/spark/conf/spark-env.sh" ]
then
  # overwrite Spark 2.1.0 config
  echo "INFO: ovewriting default spark-env.sh"
  cp /usr/local/spark/conf/spark-env.sh /usr/local/spark/2.1.0/conf
else
  # use default config
  echo "/!\ NO CUSTOM spark-env.sh PROVIDED. USING DEFAULT TEMPLATE."
  cp /usr/local/spark/2.1.0/conf/spark-env.sh.template /usr/local/spark/2.1.0/conf/spark-env.sh
fi

# Run Zeppelin
echo "Running Apache Zeppelin..."
/zeppelin/bin/zeppelin.sh
