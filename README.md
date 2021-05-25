# openstreetmap-tile-server

This is a fork of of [Openstreetmap](https://github.com/Overv/openstreetmap-tile-server)

[PBF downloads](https://download.openstreetmap.fr/extracts/asia/)

## Docker Build

    docker build --progress=plain -t map:latest .

## Docker Run

First create a Docker volume to hold the cached tiles:

    docker volume create openstreetmap-data

```
docker run \
    -p 8080:8080 \
    -v /absolute/path/to/luxembourg.osm.pbf:/data.osm.pbf \
    -v openstreetmap-data:/tmp/efs/fs1 \
    map:latest \
    run
```

If the container exits without errors, then your data has been successfully imported and you are now ready to run the tile server.

## Update map

Download (singapore.osm.pbf)[https://download.openstreetmap.fr/extracts/asia/singapore.osm.pbf] and save it in the project root as singapore.osm.pbf and build again.

## Deploy to dev

```
# Login to ECR if not logged in
aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin {YOUR_AWS_ACCOUNT_ID}.dkr.ecr.ap-southeast-1.amazonaws.com
docker build -t map:latest .
docker tag map:latest 485380287493.dkr.ecr.ap-southeast-1.amazonaws.com/map-nightly:latest
docker push 485380287493.dkr.ecr.ap-southeast-1.amazonaws.com/map-nightly:latest
```

## Performance tuning and tweaking

Details for update procedure and invoked scripts can be found here [link](https://ircama.github.io/osm-carto-tutorials/updating-data/).

### THREADS

The import and tile serving processes use 4 threads by default, but this number can be changed by setting the `THREADS` environment variable. For example:

```
docker run \
    -p 8080:8080 \
    -e THREADS=24 \
    -d map:latest \
    run
```

### CACHE

The import and tile serving processes use 800 MB RAM cache by default, but this number can be changed by option -C. For example:

```
docker run \
    -p 8080:8080 \
    -e "OSM2PGSQL_EXTRA_ARGS=-C 4096" \
    -d map:latest \
    run
```

## Troubleshooting

### ERROR: could not resize shared memory segment / No space left on device

If you encounter such entries in the log, it will mean that the default shared memory limit (64 MB) is too low for the container and it should be raised:

```
renderd[121]: ERROR: failed to render TILE ajt 2 0-3 0-3
renderd[121]: reason: Postgis Plugin: ERROR: could not resize shared memory segment "/PostgreSQL.790133961" to 12615680 bytes: ### No space left on device
```

To raise it use `--shm-size` parameter. For example:

```
docker run \
    -p 8080:8080 \
    --shm-size="192m" \
    -d map:latest \
    run
```

For too high values you may notice excessive CPU load and memory usage. It might be that you will have to experimentally find the best values for yourself.

### The import process unexpectedly exits

You may be running into problems with memory usage during the import. Have a look at the "Flat nodes" section in this README.

## License

```
Copyright 2019 Alexander Overvoorde

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
