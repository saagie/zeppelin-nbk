FROM apache/zeppelin:0.7.3

MAINTAINER Saagie

# Install Spark 2.1.0 for Hadoop 2.6
RUN cd /tmp && wget https://archive.apache.org/dist/spark/spark-2.1.0/spark-2.1.0-bin-hadoop2.6.tgz -O /tmp/spark-2.1.0-bin-hadoop2.6.tgz

RUN cd /tmp && tar -xzf spark-2.1.0-bin-hadoop2.6.tgz && \
  cp spark-2.1.0-bin-hadoop2.6/conf/log4j.properties.template spark-2.1.0-bin-hadoop2.6/conf/log4j.properties && \
  mkdir -p /usr/local/spark/2.1.0 && mv spark-2.1.0-bin-hadoop2.6/* /usr/local/spark/2.1.0 && \
  rm -rf spark-2.1.0-bin-hadoop2.6.tgz spark-2.1.0-bin-hadoop2.6

# Set Spark 2.1.0 as the default one
ENV SPARK_HOME /usr/local/spark/2.1.0

# Set Hadoop default conf dir
ENV HADOOP_CONF_DIR /etc/hadoop/conf

# Set Hive default conf dir
ENV ZEPPELIN_INTP_CLASSPATH_OVERRIDES /etc/hive/conf

# Default notebooks directory
ENV ZEPPELIN_NOTEBOOK_DIR '/notebook'

# Add a startup script that will setup Spark conf before running Zeppelin
ADD saagie-zeppelin.sh /zeppelin
RUN chmod 744 /zeppelin/saagie-zeppelin.sh

# Keep default ENTRYPOINT as apache/zeppelin is using Tini, which is great.
CMD ["/zeppelin/saagie-zeppelin.sh"]
