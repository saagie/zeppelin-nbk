# Zeppelin Datascience Notebook

This Docker image is based on official Apache Zeppelin image.
It adds some specific library versions used on Saagie's platform (such as Spark versions, etc.)

## Build the image

Run the following command:
```
docker build --no-cache -t saagie/zeppelin-nbk:v2 .
```

## Run a container

This container can run on Saagie's platform.

You need to define :
 - the port 8080
 - the base path variable : $ZEPPELIN_SERVER_CONTEXT_PATH
 - no rewrite URL                           

You can also attach a volume on /notebook to persist your Notebooks.
 

If you want to run it locally with an in-memory Spark, just run:
```
docker run -it --rm --name zeppelin -p 8080:8080 saagie/zeppelin-nbk:v2
```

 If you want to run it locally but pointing to a remote Spark cluster, run:
```
TO BE COMPLETED
```

The given volumes contain Hive, Hadoop, and Spark configuration files of your remote cluster.
The `/notebook` volume is where Zeppelin notebooks are saved.
And the `[ZEPPELIN_PORT]` variable is the port on which to run Zeppelin
