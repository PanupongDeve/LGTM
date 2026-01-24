helm install grafana grafana/grafana \
  --namespace lgtm \
  -f ./values/grafana-values.yaml