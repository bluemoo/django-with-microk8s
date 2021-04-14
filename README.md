## Prerequisites
- Docker >= v20.10.0
- Microk8s >= v1.19

## Operation
1. Pull the repository locally, and run: `./syscontrol.sh start` 
1. Check for successful startup with: `./syscontrol.sh status`
1. Navigate to http://localhost:8000/admin and you should see the django admin form.
1. Try to log in with any username + password, and you'll be rejected without other error if the server is properly talking to the server.

## Installation Notes
If you want to run docker as non-root user then you need to add it to the docker group.
https://stackoverflow.com/questions/48957195/how-to-fix-docker-got-permission-denied-issue
