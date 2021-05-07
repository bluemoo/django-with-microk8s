#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

REQUIRED_ADDONS=(
  'dns'
  'helm3'
  'host-access'
  'ingress'
  'registry'
  'storage'
)


main() {
  if [ $# -eq 0 ]; then
    show_help
    exit 1
  fi


  case $1 in
    start)
      start
      ;;
    stop)
      stop
      ;;
    restart)
      stop
      start
      status
      ;;
    status)
      status
      ;;
    postgres-logs)
      postgres_logs
      ;;
    server-logs)
      server_logs
      ;;
    startup-logs)
      startup_logs
      ;;
    server-exec)
      shift
      server_exec "$@"
      ;;
    test)
      run_tests "$@"
      ;;
    manage)
      shift
      run_manage "$@"
      ;;
    server-shell)
      server_shell
      ;;
    *)
      show_help
      exit 1
      ;;
  esac
}

start() {
  echo "Checking microk8s configuration"
  STATUS=$(microk8s.status)
  if [[ ! ($STATUS =~ "microk8s is running") ]]; then
    echo "Microk8s is not running. Try: microk8s.start"
    exit 1
  fi
  ENABLED=$(echo "${STATUS}" | sed -n '/enabled:/,$p' | sed -n '/disabled:/q;p')
  for addon in "${REQUIRED_ADDONS[@]}"; do
    if [[ ! ($ENABLED =~ $addon) ]]; then
      echo "The Microk8s addon ${addon} is not enabled. Try running: microk8s.enable ${addon}"
      exit 1
    fi
  done

  echo "Build image"
  docker build -t server:development-server -f deploy/docker/development-server/Dockerfile .

  echo "Pushing image to registry"
  docker tag server:development-server localhost:32000/server:development-server
  docker push localhost:32000/server:development-server

  echo "Setting up Secrets"
  microk8s.helm3 install development-secrets deploy/helm/development-secrets/ \
               -n development --create-namespace

  echo "Installing database"


  microk8s.helm3 install development-db deploy/helm/development-db/ \
               -n development --create-namespace

  echo "Wait for database to be ready"
  # We need to wait, because the server chart assumes a db is available for it and will try to run a migration job.
  # Helm has a bug that prevents us from using the --wait flag on the database install command, so we'll use kubectl.
  microk8s.kubectl -n development wait --for=condition=ready pod -l app=postgres

  echo "Installing server"
  microk8s.helm3 install development-app deploy/helm/development-app/ \
               -n development --create-namespace \
               --set projectDir="${PROJECT_ROOT}" \
               --set imagePullPolicy=Always \
               --set imageTag="localhost:32000/server:development-server" \
               --set uid=${UID} \
               --set gid="$(id -g)"

  echo "Configuring Ingress"
  microk8s.kubectl apply -f deploy/helm/development-app/microk8s-ingress.yaml
}

stop() {
  microk8s.helm3 -n development uninstall development-secrets development-db development-app
}

status() {
  microk8s.kubectl -n development get pods
}

postgres_logs() {
  microk8s.kubectl -n development logs -l app=postgres -f --tail 100
}

server_logs() {
  microk8s.kubectl -n development logs -l tier=server -f --tail 100
}

startup_logs() {
  microk8s.kubectl -n development logs -l tier=startup -f --tail 100
}

server_exec() {
  # This is here primarily to be used by the git pre-commit hooks. It does not pass the -it flag to kubectl exec, which
  # would result in an error, because pre-commit hooks cannot be interactive.
  local name
  name="$(kubectl -n development get pods --selector=tier=server  --no-headers -o custom-columns=":metadata.name")"
  microk8s.kubectl -n development exec "${name}" -- "$@"
}

interactive_exec() {
  local name
  name="$(kubectl -n development get pods --selector=tier=server  --no-headers -o custom-columns=":metadata.name")"
  microk8s.kubectl -n development exec -it "${name}" -- "$@"
}

server_shell() {
  interactive_exec /bin/sh
}

run_tests() {
  shift
  server_exec python manage.py test "$@"
}

run_manage() {
  interactive_exec python manage.py "$@"
}

show_help() {
  echo "Operate the project development environment."
  echo
  echo "Usage: dev.sh COMMAND"
  echo
  echo "System control commands:"
  echo "  start                        - Start the whole system in a running microk8s"
  echo "  stop                         - Uninstall all helm charts"
  echo "  restart                      - Stop, then start, the system"
  echo "  status                       - Shortcut to see the status of all pods in the system"
  echo
  echo "Component log commands:"
  echo "  postgres-logs                - View logs from postgres"
  echo "  startup-logs                 - View logs from the database migration job"
  echo "  server-logs                  - View logs from the webserver"
  echo
  echo "Application control commands:"
  echo "  test [test_label ...]        - Run django tests"
  echo "  manage [subcommand]          - Run django manage.py file in the server container"
  echo "  server-exec [command_string] - Run the command string in the server container"
  echo "  server-shell                 - Open an interactive shell in the server container"
}

main "$@"