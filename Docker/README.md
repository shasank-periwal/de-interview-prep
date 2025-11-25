# DOCKER

## Useful Commands
1. Running Containers- `docker ps`
2. All Containers- `docker ps -a`
3. Docker Images- `docker images`
4. Build Container- `docker run -dit image_id /bin/bash`
5. Start Container- `docker start container_id `
6. Stop Container- `docker stop container_id `
7. Remove Container- `docker rm container_id`
8. Remove Image- `docker rmi image_id`
9. Execute Docker Container- `docker exec -it container_id /bin/bash`
10. Copy from Docker to Local- `docker cp container_id:path local_path`
11. Copy from Local to Docker- `docker cp local_path container_id:path`
12. Get last 50 lines of logs- `docker-compose logs --tail=50`

## YAML Anchors and Aliases
```yaml
x-airflow-common: 
  &airflow-common
  image: apache/airflow:2.2.5
  environment:
    - key: value

airflow-init:
  <<: *airflow-common
  command: some-init-command
```
|  Symbol	  | Meaning                                               |
|-------------|-------------------------------------------------------|
| &anchorName | Define a reusable block of YAML config (the anchor)   |
| *anchorName | Reference (reuse) the block at another place          |
| <<:         | Merge the referenced block's keys into this structure |