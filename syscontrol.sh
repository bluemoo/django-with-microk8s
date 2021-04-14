#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

main() {
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
    *)
      echo "Unknown command"
      exit 1
      ;;
  esac
}

start() {
  echo "Build image"
  docker build -t server:development -f deploy/docker/development/Dockerfile .

  echo "Pushing image to registry"
  docker tag server:development localhost:32000/server:development
  docker push localhost:32000/server:development

  echo "Installing database"
  helm install development-db deploy/helm/development-db/ \
               -n development --create-namespace \
               --set imagePullPolicy=Always \

  echo "Wait for database to be ready"
  # We need to wait, because the server chart assumes a db is available for it and will try to run a migration job.
  # Helm has a bug that prevents us from using the --wait flag on the database install command, so we'll use kubectl.
  kubectl -n development wait --for=condition=ready pod -l app=postgres

  echo "Installing server"
  helm install development deploy/helm/development/ \
               -n development --create-namespace \
               --set projectDir="${PROJECT_ROOT}/server" \
               --set imagePullPolicy=Always \
               --set imageTag="localhost:32000/server:development" \

  echo "Configuring Ingress"
  kubectl apply -f deploy/helm/development/microk8s-ingress.yaml
}

stop() {
  helm -n development uninstall development-db development
}

status() {
  kubectl -n development get pods
}

postgres_logs() {
  kubectl -n development logs -l app=postgres -f --tail 100
}

server_logs() {
  kubectl -n development logs -l tier=server -f --tail 100
}

startup_logs() {
  kubectl -n development logs -l tier=startup -f --tail 100
}

server_shell() {
  kubectl -n development exec -it  -- /bin/sh
}

main "$@"