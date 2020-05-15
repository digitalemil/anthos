gcloud container binauthz policy export
kubectl run hello-server --image gcr.io/google-samples/hello-app:1.0 --port 8080
kubectl get pods
kubectl delete deployment hello-server
gcloud container binauthz policy import deny.yaml
kubectl run hello-server --image gcr.io/google-samples/hello-app:1.0 --port 8080
kubectl get pods
kubectl get event --template '{{range.items}}{{"\033[0;36m"}}{{.reason}}:{{"\033[0m"}}{{.message}}{{"\n"}}{{end}}'
kubectl delete deployment hello-server
gcloud container binauthz policy import allow.yaml
kubectl run hello-server --image gcr.io/google-samples/hello-app:1.0 --port 8080
kubectl get pods
