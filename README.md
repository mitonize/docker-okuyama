# docker-okuyama
Run okuyama inside of a docker container 


## Usage

データノードの起動
```
docker run -d -P -e "TZ=Asia/Tokyo" -v $(pwd)/logs:/home/okuyama/logs -v $(pwd)/keymapfile:/home/okuyama/keymapfile --name okuyama-datanode mitonize/okuyama-datanode:0.9.6.1
```

マスターノードの起動
```
docker run -d -p 8888:8888 --link okuyama-datanode:okuyama-datanode -e "TZ=Asia/Tokyo" -v $(pwd)/logs-master:/home/okuyama/logs --name okuyama-masternode mitonize/okuyama-masternode:0.9.6.1 
```

## Custom configuration
```
docker run -d -v conf/DataNode.properties:/home/okuyama/conf/DataNode.properties -v $(pwd)/logs:/home/okuyama/logs -v $(pwd)/keymapfile:/home/okuyama/keymapfile mitonize/okuyama
```

