## Prerequisites
Including minimum tested versions:
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

## Notes
If you want to run docker as non-root user then you need to add it to the docker group.
https://stackoverflow.com/questions/48957195/how-to-fix-docker-got-permission-denied-issue
