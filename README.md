# Zeppelin Datascience Notebook

This Docker image is based on official Apache Zeppelin image.
It adds some specific library versions used on Saagie's platform (such as Spark versions, etc.)

## Build the image

Run the following command:
```
docker build -t saagie/zeppelin:sp-xxx .
```

Where `sp-xxx` is a tag corresponding to the minimum Saagie platform version with which this Zeppelin image is compatible.


## Run a container

This container can run without configuration on Saagie's platform, or can run locally using:

```
docker run -d --rm --name zeppelin -p 8080:8080 \
  -v $(pwd)/notebook/:/notebook/ \
  -v $(pwd)/conf/hive/hive-site.xml:/etc/hive/conf/hive-site.xml \
  -v $(pwd)/conf/hadoop/:/etc/hadoop/conf/ \
  -v $(pwd)/conf/spark/spark-env.sh:/usr/local/spark/conf/spark-env.sh \
  -v $(pwd)/conf/spark/spark-defaults.conf:/tmp/spark-defaults.conf \
  saagie/zeppelin:sp-xxx
```

The given volumes contain Hive, Hadoop, and Spark configuration files.
And the `/notebook` volume is where Zeppelin notebooks are saved.
