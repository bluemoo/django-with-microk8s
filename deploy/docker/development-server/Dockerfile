FROM python:3.9-slim

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# The /opt/project file should end up corresponding to the root directory of this project from a file path perspective.
# So, /opt/project/server is where manage.py sits, etc. In the development helm charts, it's expected that the actual
# root project directory will be mapped to /opt/project so that things like pre-commit hooks can run on all of the files
# inside the container. However, in a production version of the system, it is more likely that you'll just want the
# webserver files mapped to /opt/project/server, and that /opt/project would only contain the server/ directory.
RUN mkdir /opt/project
COPY deploy/docker/development-server/hook-requirements.txt /opt/project
COPY deploy/docker/development-server/requirements.txt /opt/project

RUN pip install -r /opt/project/hook-requirements.txt -r /opt/project/requirements.txt
