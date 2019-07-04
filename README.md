`export GO111MODULE=on`

### Install `avalance` for sending metrics to the remote ingestors 
```
go get -d  github.com/open-fresh/avalanche/cmd@master
cd $GOPATH/src/github.com/open-fresh/avalanche/cmd
go build -o $GOPATH/bin/avalanche
```

### Install compatible prometheus format ingestors.

```
go get -d github.com/improbable-eng/thanos/cmd/thanos@00207cb74aca6f19cab41cb150839063d455742e
cd $GOPATH/src/github.com/improbable-eng/thanos/cmd/thanos
go build -o $GOPATH/bin/thanos

go get -d  github.com/VictoriaMetrics/VictoriaMetrics/app/victoria-metrics@master
cd $GOPATH/src/github.com/VictoriaMetrics/VictoriaMetrics/app/victoria-metrics
go build -o $GOPATH/bin/victoria-metrics

```

### Run ingestors
```
thanos receive
victoria-metrics
```

### Send metrics to ingestors
```
# Thanos
export URL=http://127.0.0.1:19291/api/v1/receive

avalanche \
--remote-url=$URL \
--metric-count=100 \
--label-count=10 \
--series-count=100 \
--remote-samples-count=1000 \
--value-interval=10


# VM
export URL=http://127.0.0.1:8428/api/v1/write 
# Same command as above.


```
