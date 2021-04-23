FROM python:3.9-slim

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN mkdir /opt/server
COPY deploy/docker/development-server/requirements.txt /opt/server

RUN pip install -r /opt/server/requirements.txt

WORKDIR /opt/server

