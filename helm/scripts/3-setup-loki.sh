# ติดตั้ง Loki
helm install loki grafana/loki \
  --namespace lgtm -f ./values/loki-values.yaml