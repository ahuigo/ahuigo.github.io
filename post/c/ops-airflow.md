---
title: Airflow
date: 2019-12-06
private: true
---
# Airflow

## root
to get a root shell inside a running container, 

    docker exec -u root -ti my_airflow_container bash

or to start a new container as root.

    docker run --rm -ti -u root --entrypoint bash puckel/airflow 