# Django with MicroK8s
## Start Building Your Project
This project provides a Django web app running as a single node Kubernetes
cluster in microk8s. It is meant to make it as easy as possible to begin
building a project with a minimum of initial configuration.

This is both a reference and an actual github template that
can be used to quickly start development. After
installing prerequisites and downloading this repository, only one command is
needed to have a working, browsable application.

## Provided Tools
  - [A running Django server](deploy/helm/development-app/templates/server.yaml) 
  - [PostgreSQL database](deploy/helm/development-db/templates/postgres.yaml)
  - [Redis Cache](deploy/helm/development-app/templates/redis.yaml)
  - [Ingress configuration](deploy/helm/development-app/microk8s-ingress.yaml) to access the web server from your local machine
  - Automatic [database migration](deploy/helm/development-app/templates/migrations-job.yaml) on start
  - Automatic web-server reloading on code changes
  - [Demonstration of Kubernetes Secrets](deploy/helm/development-secrets/templates/secrets.yaml) integration
  - [Pre-commit hooks](.pre-commit-config.yaml) with style checking and linting
  - Continuous Integration via [Github Actions](.github/workflows/push-actions.yaml)
  - A [shell script](dev.sh) with useful commands to interact with the system

## Prerequisites
You'll need to install the following software:
- [Docker](https://docs.docker.com/get-docker/) >= v20.10.0
- [Microk8s](https://microk8s.io/docs) >= v1.21
- [Pre-commit](https://pre-commit.com/) >= 2.12.1

Note that the system has only been tested on Ubuntu 18+, but should
theoretically work for any host OS on which Microk8s and docker can be
installed.

## Initial Operation
1) Install pre-requisites.
1) Download the repository:

    ```
    git clone git@github.com:bluemoo/django-with-microk8s.git
    ```

1) Install pre-commit hooks:

    ```
    pre-commit install
    ```
1) Start Microk8s and enable required add-ons:
    
    ```
    microk8s.start
    microk8s enable helm3 dns storage registry host-access ingress
    ```
1) Start the system:
    ```
    ./dev.sh start
    ```
1) Check for successful startup with: 
   ```
   ./dev.sh status
   ```
1) Navigate to http://localhost:8000 and you should see Django tell you it was 
   installed successfully!

## Example System Start
```
$ microk8s.start
Started.

$ microk8s enable helm3 dns storage registry host-access ingress
Enabling Helm 3
Fetching helm version v3.5.0.
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 11.7M  100 11.7M    0     0  8430k      0  0:00:01  0:00:01 --:--:-- 8430k
Helm 3 is enabled
Addon dns is already enabled.
Addon storage is already enabled.
Addon registry is already enabled.
Addon host-access is already enabled.
Addon ingress is already enabled.


$ ./dev.sh start
Checking microk8s configuration
Build image
Sending build context to Docker daemon  7.146MB
<-- Snipped Steps -->
Successfully built aeb2100b9b07
Successfully tagged server:development-server
Pushing image to registry
The push refers to repository [localhost:32000/server]
<-- Snip Pushing Image -->
Setting up Secrets
<-- Snip -->
Installing database
<-- Snip -->
Wait for database to be ready
pod/postgres-statefulset-0 condition met
Installing server
<-- Snip -->
Configuring Ingress
configmap/nginx-ingress-tcp-microk8s-conf unchanged
daemonset.apps/nginx-ingress-microk8s-controller unchanged

$ ./dev.sh status
NAME                                  READY   STATUS      RESTARTS   AGE
development-server-7f5c56ff54-wmgf5   1/1     Running     0          9s
migration-job-gqd65                   0/1     Completed   0          13s
postgres-statefulset-0                1/1     Running     0          18s
redis-statefulset-0                   1/1     Running     0          9s

$ wget http://localhost:8000/
2021-05-11 20:07:00 (84,3 MB/s) - ‘index.html’ saved [10697/10697]

$ grep "The install worked successfully! Congratulations!" index.html 
        <title>The install worked successfully! Congratulations!</title>
        <h1>The install worked successfully! Congratulations!</h1>

$ ./dev.sh test
.System check identified no issues (0 silenced).
..
----------------------------------------------------------------------
Ran 3 tests in 0.001s

OK

```

## Development Workflows
### dev.sh
The project comes with a shell script `dev.sh` that contains helpful commands to interact
with the running system. In particular, it has options to install/uninstall the system, 
run django  management commands, and run django tests. For a full set of options, simply 
type: `./dev.sh help`

### Hot code reloading
The development server mounts files directly from your file system, so any changes to 
python files will be automatically noticed and result in the server automatically reloading
the code:
```
$ ./dev.sh server-logs
10.1.97.1 - - [11/May/2021 18:33:12] "GET / HTTP/1.1" 200 -
10.1.97.1 - - [11/May/2021 18:33:12] "GET / HTTP/1.1" 200 -
 * Detected change in '/opt/project/server/appsecrets.py', reloading
 * Restarting with stat
Performing system checks...

System check identified no issues (0 silenced).

Django version 3.2.2, using settings 'settings'
Development server is running at http://0.0.0.0:8000/
Using the Werkzeug debugger (http://werkzeug.pocoo.org/)
Quit the server with CONTROL-C.
```
Thus, you can edit, save, and see your changes in your app very quickly.

### Database migrations
As this is a development environment, migrations are automatically applied on system start
up, so you'll have an empty django database schema from the beginning. You can perform all
other database interactions as you would normally via the Django manage command provided 
by `dev.sh`:
```
$ ./dev.sh manage makemigrations
No changes detected

$ ./dev.sh manage migrate
Operations to perform:
  Apply all migrations: admin, auth, contenttypes, sessions
Running migrations:
  No migrations to apply.
```

### Testing
While django tests can be run via the manage command, the `dev.sh` file provides a small
shortcut, allowing you to simply use `./dev.sh test`. You can also pass one or more test
labels:
```
$ ./dev.sh test
...
----------------------------------------------------------------------
Ran 3 tests in 0.001s

OK
System check identified no issues (0 silenced).
```
```
$ ./dev.sh test tests.test_appsecrets.AppSecretsIntegrationTest
.
----------------------------------------------------------------------
System check identified no issues (0 silenced).
Ran 1 test in 0.000s

OK
```

## Next steps
This development environment should server you well until you're ready to actually deploy
your app to production. However, if you're new to Django, you can easily pick up the
tutorial from [Creating the Polls app](https://docs.djangoproject.com/en/3.2/intro/tutorial01/#creating-the-polls-app).
Just remember that instead of typing `python manage.py startapp polls` you should use
`./dev.sh manage startapp polls` instead. Good luck!

## Notes
If you want to run docker as non-root user then you need to add it to the docker group.
https://stackoverflow.com/questions/48957195/how-to-fix-docker-got-permission-denied-issue
