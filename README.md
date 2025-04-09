# sample-metrics
This repository contains sample spring boot application for SLO demo purposes

# prerequisite
* install java-sdk 17, docker, minikube, helm, kubectl

# upload docker image to docker hub
```bash
# build jar
mvn clean install
# docker build image
docker build -t wojciech13/wojtek:<tag-name> .
# docker push to dockerhub
docker push wojciech13/wojtek:<tag-name>
# 
```

# deploy to minikube
```bash
# build jar
mvn clean install
# docker build image
docker build -t wojciech13/wojtek:<tag-name> .
# docker push to dockerhub
docker push wojciech13/wojtek:<tag-name>
# 
```

# install prometheus grafana stack on minikube (minikube must be started)
```bash
# https://github.com/prometheus-community/helm-charts
# add helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# install prometheus stack
helm install prometheus prometheus-community/kube-prometheus-stack --version 45.7.1 --namespace monitoring --create-namespace
# check if prometheus stack is running
kubectl get pods -n monitoring
```

# deploy spring boot app to cluster
```bash
# go to kubernetes directory
cd kubernetes
# apply resources
kubectl apply -f .
# check if springboot-app is running
kubectl get pods -n monitoring
```

# deploy prometheus rules
```bash
# go to prometheus directory
cd prometheus
# apply resources
kubectl apply -f .
# check if prometheus rules applied properly
kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090
# open in browser url http://localhost:9090/rules
# search by SLOErrorBudgetSaturated and springboot-app-slo.rules (good_request and total_requests)
```

