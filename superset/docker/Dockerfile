FROM apache/superset:5.0.0

USER root

# Required for building the MySQL Python lib. Maybe this can be optimized later
# using a multi stage build that keeps compiler tools out of the final image.
RUN apt-get update && apt-get install -y \
    python3-dev \
    default-libmysqlclient-dev \
    build-essential \
    pkg-config

RUN . /app/.venv/bin/activate && \
    uv pip install \
    mysqlclient \
    psycopg2-binary

USER superset

CMD ["/app/docker/entrypoints/run-server.sh"]
