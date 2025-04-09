# sample-metrics
This repository contains sample spring boot application for SLO demo purposes

# Prerequisites
* install java-sdk 17, docker, minikube, helm, kubectl, maven

# Upload docker image to docker hub
```bash
# build jar
mvn clean install
# docker build image
docker build -t wojciech13/wojtek:<tag-name> .
# docker push to dockerhub
docker push wojciech13/wojtek:<tag-name>
# 
```

# Install prometheus grafana stack on minikube (minikube must be started)
```bash
# https://github.com/prometheus-community/helm-charts
# add helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# install prometheus stack
helm install prometheus prometheus-community/kube-prometheus-stack --version 45.7.1 --namespace monitoring --create-namespace
# check if prometheus stack is running
kubectl get pods -n monitoring
```

# Deploy spring boot app to minikube cluster
```bash
# go to kubernetes directory
cd kubernetes
# apply resources
kubectl apply -f .
# check if springboot-app is running
kubectl get pods -n monitoring
```

# Deploy prometheus rules
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

# Exposing
```bash
# expose springboot-app, prometheus and grafana to localhost
# springboot-app port forwarding localhost:8080
kubectl port-forward -n monitoring svc/springboot-app 8080:8080
# grafana port forwarding localhost:3080 - password to grafana is in config map
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

# SLO assumptions
* SLO is 99,9%. 99,9% of requests have status (OK) 2xx
* Error budget is 0,1%
* Prometheus rules are:
1. `sum(rate(http_request_total{job="springboot-app", status=~"2.."}[5m]))` success requests
2. `sum(rate(http_request_total{job="springboot-app"}[5m]))` total request
* Visualization of error budget is: `(1 - (sum(slo:good_requests:rate5m) / sum(slo:total_requests:rate5m))) / 0.001`

* If value is:
`< 1.0` we are in budget
`> 1.0` we exceeded budget
`= 0` equals zero means there are no errors

* alert `(1 - (sum(slo:good_requests:rate5m) / sum(slo:total_requests:rate5m))) / 0.001 > 1` (trigger when exceeded error budget, so it must be above 1)

# Simulate errors/ok, sending request to springboot-app (feel free to use postman or more advanced tools)
```bash
# simulate error
curl localhost:8080/error
# simulate ok
curl localhost:8080
```
