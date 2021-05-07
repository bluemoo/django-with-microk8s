# Django with MicroK8s
## Start Building Your Project
This project is meant to be both a reference and an actual github template that
can be used to quickly start development on a Django-based web app. After
installing prerequisites and downloading this repository, only one command is
needed to have a working, browsable application.

The web app runs in a Kubernetes cluster run by microk8s, which allows us to
ignore a lot of complexity normally involved with installing software for local
development.

## Provided Tools
  - A running Django server 
  - PostgreSQL database
  - Redis Cache
  - Ingress configuration to access the web server from your local machine
  - Automatic database migration on start
  - Automatic web-server reloading on code changes
  - Demonstration of Kubernetes Secrets integration
  - Pre-commit hooks with style checking and linting
  - Continuous Integration via Github Actions
  - A shell script with useful commands to interact with the system


## Prerequisites
You'll need to install the following software:
- Docker >= v20.10.0
- Microk8s >= v1.21
- [Pre-commit](https://pre-commit.com/) >= 2.12.1

## Installation
```
pre-commit install
```
```
microk8s.start
microk8s enable helm3 dns storage registry host-access ingress
```

## Operation
1. Pull the repository locally, and run: `./dev.sh start` 
1. Check for successful startup with: `./dev.sh status`
1. Navigate to http://localhost:8000/admin and you should see the django admin form.
1. Try to log in with any username + password, and you'll be rejected without other error if the server is properly talking to the server.

## Workflow

## Notes
If you want to run docker as non-root user then you need to add it to the docker group.
https://stackoverflow.com/questions/48957195/how-to-fix-docker-got-permission-denied-issue
