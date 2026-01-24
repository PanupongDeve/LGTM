helm install promtail grafana/promtail \
  --namespace lgtm \
  -f ./values/promtail-values.yaml