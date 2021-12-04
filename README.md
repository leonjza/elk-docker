# elk-docker

ELK stack in Docker, with documentation issues fixed.

## info

This repo adds nothing different other than having a working example of the `docker-compose` setup described [here](https://www.elastic.co/guide/en/elastic-stack-get-started/current/get-started-docker.html), the way I wanted it.

## instructions

Setup the Linux host

```bash
sysctl -w vm.max_map_count=262144
```

After cloning, run these in the `elk-docker` dir:

```bash
docker-compose -f create-certs.yml run --rm create_certs
docker-compose up -d
```

Give the stack ~60 seconds to do whatever it does.

Now, get passwords to use it:

```bash
docker-compose exec es-node01 /bin/bash -c "bin/elasticsearch-setup-passwords auto --batch --url https://es-node01:9200"
```

Should output something along these lines

```text
Changed password for user apm_system
PASSWORD apm_system = IAniMOR30oTYLzXgiUTG

Changed password for user kibana_system
PASSWORD kibana_system = JcQqrfzgNV252iTVNfct

Changed password for user kibana
PASSWORD kibana = JcQqrfzgNV252iTVNfct

Changed password for user logstash_system
PASSWORD logstash_system = YCdnOaJiyPI42CpHOwhA

Changed password for user beats_system
PASSWORD beats_system = O13EDZcQeOfVLTthkvtC

Changed password for user remote_monitoring_user
PASSWORD remote_monitoring_user = spxKa5yy1WwUy3CW1pZa

Changed password for user elastic
PASSWORD elastic = 7ivx2Jp17QFQCuZK1vEP
```

Now, replace the password in the `ELASTICSEARCH_PASSWORD: CHANGEME` line to that which you just for for `kibana_system`. Using the example above, that means the line will now be:

```yaml
ELASTICSEARCH_PASSWORD: JcQqrfzgNV252iTVNfct
```

Brind the stack down and back up and you should be golden.

```bash
docker-compose stop
docker-compose up -d
```
