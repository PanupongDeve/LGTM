# 1. เพิ่ม Grafana Helm Repository (สำหรับ Grafana, Loki, Tempo)
helm repo add grafana https://grafana.github.io/helm-charts
# 2. เพิ่ม Prometheus Community Helm Repository (สำหรับ Prometheus)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# อัปเดตรายการ charts
helm repo update