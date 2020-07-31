# Cloud Console Helm chart

- Helm Template
```
export RELEASE_NAME="lma-cloud-console"
export CHART_DIR="$( pwd )/cloud-console"
export CHART_VALUE="$( pwd )/values-suy.yaml"

helm template $CHART_DIR -f $CHART_VALUE --namespace fed --name $RELEASE_NAME
```

- Helm Install
```
export RELEASE_NAME="lma-cloud-console"
export CHART_DIR="$( pwd )/cloud-console"
export CHART_VALUE="$( pwd )/values-suy.yaml"

helm install $CHART_DIR -f $CHART_VALUE --name $RELEASE_NAME --namespace fed
```


- Helm Upgrade
```
export RELEASE_NAME="lma-cloud-console"
export CHART_DIR="$( pwd )/cloud-console"
export CHART_VALUE="$( pwd )/values-suy.yaml"

helm upgrade $RELEASE_NAME $CHART_DIR -f $CHART_VALUE --install --namespace fed

# ex)
# helm upgrade lma-cloud-console ./cloud-console -f ./values-doj.yaml --install --namespace fed
# helm upgrade lma-cloud-console ./cloud-console -f ./values-suy.yaml --install --namespace fed
```

