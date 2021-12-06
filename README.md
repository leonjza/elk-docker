# elk-docker

ELK stack in Docker, with documentation issues fixed.  
_This is a lab env setup with insecure configs / hardcoded keys. Don't use this anywhere important_

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
docker-compose exec es-node01 /bin/bash -c "bin/elasticsearch-setup-passwords auto --batch --url https://es-node01:9200" > credentials.txt
```

Should result in a file with output something along these lines

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

Now, replace the password in the environment file (`.env`) for `KIBANA_SYSTEM_PASSWORD` with the newly generated one. This one liner should do it:

```bash
sed -i "s/KIBANA_SYSTEM_PASSWORD=CHANGEME/KIBANA_SYSTEM_PASSWORD=$(cat credentials.txt | grep 'kibana_system =' | awk '{ print $4 }')/g" .env
```

While you are here, update the password used to setup the fleet server (`ELASTIC_PASSWORD`) as well:

```bash
sed -i "s/ELASTIC_PASSWORD=CHANGEME/ELASTIC_PASSWORD=$(cat credentials.txt | grep 'elastic =' | awk '{ print $4 }')/g" .env
```

Bring the stack down and back up and you should be golden.

```bash
docker-compose stop
docker-compose up -d
```

Your login URL will be something like <https://192.168.241.30:5601/>, using `elastic:7ivx2Jp17QFQCuZK1vEP` as the credentials (generated in the previous step)

## fleet

Getting the fleet server up takes a bit more config. If you check `docker-compose ps` now, you will probably have the `fleet-server01` service in an exited state. Let's fix that.

---

Setup the fleet server on the same host that has the stack. We install it on the bare metal here as it's also an agent.

Navigate to Management -> Fleet. Download the latest agent and install it. `dpkg -i` should do it.

Step 3 deployment mode is quick start (this is a lab), <https://127.0.0.1:8220> is your fleet server (will be the same host as the docker stack) (**note the https**), note your service token (dunno where else we use this yet).

Before we run the command, go to "Fleet Settings" at the top right, and flip the "Elasticsearch Host" from <http://localhost:9200> to <https://localhost:9200> (note the https there).

Finally, copy the "Start Fleet Server" command. We're going to edit it before we run it. The default command will not have you set the CA generated in the `create_certificates` step, so we need to add that. In my case, the docker stack lives in `/root/elk-docker`. If its different, update to the path to `ca.crt`.

```bash
elastic-agent enroll  -f \
 --fleet-server-es=https://localhost:9200 \
 --fleet-server-service-token=AAEAAWVsYXN0aWMvZmxlZXQtc2VydmVyL3Rva2VuLTE2Mzg2MzE0MzQ1MTQ6VWY1UEpmdUdRbGV6a25SOGdWM0ZFUQ \
 --fleet-server-policy=8c764c80-5515-11ec-97db-6dfa850f060a \
 --fleet-server-es-ca=/root/elk-docker/certs/ca/ca.crt
```  

Once done, enable and start the agent service.

```bash
systemctl start elastic-agent.service
systemctl enable elastic-agent.service
```

Back in the WebUI you should see the "Fleet Server Connected!" message.

## adding agents

Because we used the "quick setup" mode for Fleet, remember to add the `--insecure` flag when you install the agent on hosts. Also, take note of the server URL. It is not localhost like Kibana will tell you.
