# setup linux stuff
sysctl -w vm.max_map_count=262144

# docker
docker-compose -f create-certs.yml run --rm create_certs
docker-compose -f elastic-docker-tls.yml up -d

echo " sleeping for 60 seconds for elk to do.. well whatever... just wait."
sleep 60

docker-compose exec es-node01 /bin/bash -c "bin/elasticsearch-setup-passwords auto --batch --url https://es-node01:9200"

exit
---
docker-compose stop
docker-compose -f elastic-docker-tls.yml up -d
docker-compose logs -f

---
fleet service token: AAEAAWVsYXN0aWMvZmxlZXQtc2VydmVyL3Rva2VuLTE2Mzg2MjUzMTAyNjc6NVdJeXNXV3FTS3lES3BmVm5oT2xIQQ

---
elastic-agent enroll  -f \
 --fleet-server-es=https://localhost:9200 \
 --fleet-server-service-token=AAEAAWVsYXN0aWMvZmxlZXQtc2VydmVyL3Rva2VuLTE2Mzg2MjUzMTAyNjc6NVdJeXNXV3FTS3lES3BmVm5oT2xIQQ \
 --fleet-server-policy=baae2630-5507-11ec-9af6-8bb9df186429 \
 --fleet-server-es-ca=/root/elk/tls/certs/ca/ca.crt
---

.\elastic-agent.exe install -f --url=https://192.168.241.30:8220 --enrollment-token=bWZDc2hYMEJkSV90azZsQXRLTkg6TFJVRXhfaVNRc21nbS1lbmxxdkRLUQ== --insecure

---