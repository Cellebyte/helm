# Dashboard install

##### Warning the dashboard is not recommended for production use.

Run the following manifests
```json
kubectl apply -f admin-role-binding.yaml
kubectl apply -f dashboard-adminuser.yaml
```

Then Please follow instructions on this page:
https://github.com/kubernetes/dashboard

Obtain your login token using:
```json
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
```

login to the [Dashboard](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#)
