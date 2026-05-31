FROM apache/superset:6.0.0

USER root

# Required for building the MySQL Python lib. Maybe this can be optimized later
# using a multi stage build that keeps compiler tools out of the final image.
RUN apt-get update && apt-get install -y \
    python3-dev \
    default-libmysqlclient-dev \
    build-essential \
    pkg-config

# fastmcp powers the built-in MCP server (`superset mcp run`). It ships with
# newer Superset images, but we pin it here so the MCP sidecar is guaranteed to
# have it on the 6.0.0 base image.
RUN . /app/.venv/bin/activate && \
    uv pip install \
    mysqlclient \
    psycopg2-binary \
    fastmcp

USER superset

CMD ["/app/docker/entrypoints/run-server.sh"]
