help:
	@echo "Some tools to ease the review of this repo"
	@echo "fooo            - something"
	@echo "init            - Initialise a cluster in a project in gcloud"
	@echo "deploy          - Deploy the applications to gke"

PROJECT=clever-heisenberg-project

.PHONY: init
init:
	gcloud container clusters create $(PROJECT) --num-nodes=3
	gcloud container clusters get-credentials standard-cluster-1 --zone europe-west1-c --project $(PROJECT)

.PHONY: deploy
deploy: deploy-volumeclaims create-secret deploy-mysql deploy-website
	@echo "Deployed."
	kubectl get services

.PHONY: deploy-volumeclaims
deploy-volumeclaims:
	kubectl apply -f k8s/website-volumeclaim.yaml
	kubectl apply -f k8s/mysql-volumeclaim.yaml
	sleep 5
	kubectl get pvc

.PHONY: create-secret
create-secret: .secret
	kubectl create secret generic mysql --from-literal=password=$(shell cat .secret)

.PHONY: deploy-mysql
deploy-mysql:
	kubectl create -f k8s/mysql.yaml
	kubectl get pod -l app=mysql
	kubectl create -f k8s/mysql-service.yaml
	kubectl get service mysql

.PHONY: deploy-website
deploy-website:
	kubectl create -f k8s/website.yaml
	kubectl get pod -l app=website
	kubectl create -f k8s/website-service.yaml
	kubectl get service website

.PHONY: deploy-stackdriver
deploy-stackdriver:
	kubectl create clusterrolebinding cluster-admin-binding \
		--clusterrole cluster-admin \
		--user "$(gcloud config get-value account)"
	kubectl create -f monitoring/adapter.yaml
	kubectl get pods --all-namespaces | grep metrics
	sleep 5
	kubectl get --raw "/apis/external.metrics.k8s.io/v1beta1" | jq


.PHONY: destroy
destroy:
	kubectl delete -f k8s/mysql-service.yaml
	kubectl delete -f k8s/mysql-volumeclaim.yaml
	kubectl delete secret mysql
	kubectl delete deployment mysql
	kubectl delete -f k8s/website-service.yaml
	kubectl delete -f k8s/website-volumeclaim.yaml
	kubectl delete deployment website
