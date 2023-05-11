# Sensu7 with Yugabyte Sandbox

## Architecture

- Physical  
  
![sensu7_phys_arch](https://github.com/voltaxic-rift/sensu7-with-yugabyte-sandbox/assets/19828725/cbfac632-6a84-4737-be39-792c69a2f340)  
  
- Logical  
  
![sensu7_logi_arch](https://github.com/voltaxic-rift/sensu7-with-yugabyte-sandbox/assets/19828725/9e6eddd7-9680-40a3-8e53-555a5621b6bc)  

## Getting started

```
cp .env.sample .env

vagrant up --no-parallel

vagrant ssh monitor1 -c "sudo bash /vagrant/scripts/prepare_packages.sh"

vagrant ssh monitor1 -c "sudo bash /vagrant/scripts/setup_minio.sh"
vagrant ssh monitor2 -c "sudo bash /vagrant/scripts/setup_minio.sh"
vagrant ssh monitor3 -c "sudo bash /vagrant/scripts/setup_minio.sh"

vagrant ssh monitor1 -c "sudo bash /vagrant/scripts/setup_yugabytedb.sh"
vagrant ssh monitor2 -c "sudo bash /vagrant/scripts/setup_yugabytedb.sh"
vagrant ssh monitor3 -c "sudo bash /vagrant/scripts/setup_yugabytedb.sh"

vagrant ssh monitor1 -c "sudo bash /vagrant/scripts/setup_mimir.sh"
vagrant ssh monitor2 -c "sudo bash /vagrant/scripts/setup_mimir.sh"
vagrant ssh monitor3 -c "sudo bash /vagrant/scripts/setup_mimir.sh"

vagrant ssh monitor1 -c "sudo bash /vagrant/scripts/setup_sensu_backend.sh"
vagrant ssh monitor2 -c "sudo bash /vagrant/scripts/setup_sensu_backend.sh"
vagrant ssh monitor3 -c "sudo bash /vagrant/scripts/setup_sensu_backend.sh"

vagrant ssh monitor1 -c "sensu-backend init --cluster-admin-username admin --cluster-admin-password admin"

vagrant ssh monitor1 -c "sensuctl configure -n --username admin --password admin --namespace default --url 'http://localhost:8080'"
vagrant ssh monitor2 -c "sensuctl configure -n --username admin --password admin --namespace default --url 'http://localhost:8080'"
vagrant ssh monitor3 -c "sensuctl configure -n --username admin --password admin --namespace default --url 'http://localhost:8080'"

vagrant ssh monitor1 -c "sudo bash /vagrant/scripts/setup_sensu_agent.sh"
vagrant ssh monitor2 -c "sudo bash /vagrant/scripts/setup_sensu_agent.sh"
vagrant ssh monitor3 -c "sudo bash /vagrant/scripts/setup_sensu_agent.sh"

vagrant ssh monitor1 -c "sudo bash /vagrant/scripts/setup_nginx.sh"
vagrant ssh monitor2 -c "sudo bash /vagrant/scripts/setup_nginx.sh"
vagrant ssh monitor3 -c "sudo bash /vagrant/scripts/setup_nginx.sh"

vagrant ssh monitor1 -c "sudo bash /vagrant/scripts/setup_grafana.sh"
vagrant ssh monitor2 -c "sudo bash /vagrant/scripts/setup_grafana.sh"
vagrant ssh monitor3 -c "sudo bash /vagrant/scripts/setup_grafana.sh"
```
