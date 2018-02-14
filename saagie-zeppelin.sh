#!/bin/bash

# As volumes are mounted at container startup,
# we need to grab mounted Spark conf and overwrite the default one before
# before running Zepplin
if [ -f "/usr/local/spark/conf/spark-env.sh" ]
then
  # overwrite Spark 2.1.0 config
  echo "INFO: ovewriting default spark-env.sh"
  cp /usr/local/spark/conf/spark-env.sh /usr/local/spark/2.1.0/conf
  chmod 755 /usr/local/spark/2.1.0/conf/spark-env.sh
  #FIXME: Spark UI hard coded port
  sed -i -e 's/\$PORT0/12121/g' /usr/local/spark/2.1.0/conf/spark-env.sh
else
  # use default config
  echo "/!\ NO CUSTOM spark-env.sh PROVIDED. USING DEFAULT TEMPLATE."
  cp /usr/local/spark/2.1.0/conf/spark-env.sh.template /usr/local/spark/2.1.0/conf/spark-env.sh
fi

# Create Zeppelin conf
#FIXME: do not hard code
echo "export MASTER= mesos://zk://zk1:2181,zk2:2181,zk3:2181,zk4:2181,zk5:2181,zk6:2181,zk7:2181/mesos" > /zeppelin/conf/zeppelin-env.sh

# Run Zeppelin
echo "Running Apache Zeppelin..."
/zeppelin/bin/zeppelin.sh
