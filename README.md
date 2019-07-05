### Build env setup
```
export GO111MODULE=on
mkdir tmp
cd tmp

```

### Install `avalance` for sending metrics to the remote ingestors 
```
git clone https://github.com/krasi-georgiev/avalanche.git
cd avalanche
git checkout remote-write-samples-count
go build -o avalanche ./cmd
cd ../

```

### Install compatible prometheus format ingestors.

```
git clone https://github.com/cortexproject/cortex.git
cd cortex
go build ./cmd/cortex
cd ../

git clone https://github.com/improbable-eng/thanos.git
cd thanos
go build ./cmd/thanos
cd ../

git clone https://github.com/VictoriaMetrics/VictoriaMetrics.git
cd VictoriaMetrics
go build ./app/victoria-metrics
cd ../

```

### Run ingestors
```
cortex/cortex -config.file=./docs/single-process-config.yaml -distributor.ingestion-rate-limit=0 # might need to specify ingester.lifecycler.interface=netInerfaceName
thanos/thanos receive
VictoriaMetrics/victoria-metrics
```

### Send metrics to ingestors
```
#Cortex 
export URL=http://127.0.0.1:9009/api/prom/push

avalanche/avalanche \
--remote-url=$URL \
--metric-count=100 \
--label-count=10 \
--series-count=100 \
--remote-samples-count=1000 \
--value-interval=10

# Thanos
export URL=http://127.0.0.1:19291/api/v1/receive
# Same command as above.

# VM
export URL=http://127.0.0.1:8428/api/v1/write 
# Same command as above.


```
