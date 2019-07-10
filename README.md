
## Run prometheus compatible ingestors.

```
docker run -d --net=host --name=cortex -v $(pwd)/config/cortex.yml:/etc/cortex.yml  quay.io/cortexproject/cortex:master-1b36b439 -config.file=/etc/cortex.yml -distributor.ingestion-rate-limit=0 # might need to specify -ingester.lifecycler.interface=netInerfaceName

docker run -d --net=host --name=thanos improbable/thanos:master-2019-07-09-18049ff3 receive

docker run -d --net=host --name=vm victoriametrics/victoria-metrics
```

## Run prometheus to collect the internal metrics of the ingestors.
```
docker run -d --net=host --name=promMeta -v $(pwd)/config/promMeta.yml:/etc/promMeta.yml prom/prometheus:master --config.file=/etc/promMeta.yml
```

## Run Grafana to display the ingestor metrics.
```
docker run -d --net=host --name=grafana grafana/grafana
```

Add data source named `PromMeta` with `127.0.0.1:9090`

Import the dashboard to compare resources usage.
`./config/dashboardResources.json`

Optional:
- Import VM dashboard: https://grafana.com/dashboards/10229
- Import Thanos dashboard: https://github.com/improbable-eng/thanos/tree/master/examples/grafana
- Import Cortex dashboard: https://github.com/cortexproject/cortex/tree/master/docs/dashboards



## Send metrics to ingestors

```
# Cortex
export URL=http://127.0.0.1:9009/api/prom/push

# Short test
docker run -d --net=host --name=avalanche krasimir/avalanche \
--remote-url=$URL \
--metric-count=100 \
--label-count=10 \
--series-count=100 \
--remote-samples-count=1000 \
--value-interval=10

# Long test
docker run -d --net=host --name=avalanche krasimir/avalanche \
--remote-url=$URL \
--metric-count=100 \
--label-count=10 \
--series-count=100 \
--remote-samples-count=1000000 \
--value-interval=10

# Thanos
export URL=http://127.0.0.1:19291/api/v1/receive
# Same command as above.

# VM
export URL=http://127.0.0.1:8428/api/v1/write 
# Same command as above.
```

