# Docker

Superset publishes a few types of [Docker images](https://superset.apache.org/docs/6.0.0/installation/docker-builds). One type is the "dev" image which includes all you'll need no matter which database you're using for the metadata database and which databases you connect to for your dashboards. But you aren't supposed to use that image in production.

So they recommend their "lean" image for production. And you must install your database drivers for which databases you're using. For us, this means PostgreSQL (for the metadata database) and MySQL (for the data warehouse database for our dashboards).

The file `Dockerfile` here is what I used to make a Docker image for this purpose. I tested it and found that it worked. I used some docs they'd published in their GitHub (similar to that doc page linked above) to learn how to install the pip packages for this.

I believe it's possible to make a smaller image (this one is about 4.3 GB), better for production, by writing our own Dockerfile that uses a multistage build to build Superset from scratch and copies the completed virtual env (but not the system libraries required to compile the MySQL driver) from the first stage to the final stage. Leaving that as a TODO. I think it'll only save us about 500 MB anyways.
