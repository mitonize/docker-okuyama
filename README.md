# docker-okuyama
Run okuyama inside of a docker container 

## Usage
```
docker run -d -v $(pwd)/logs:/home/okuyama/logs -v $(pwd)/keymapfile:/home/okuyama/keymapfile mitonize/okuyama
```

## Custom configuration
```
docker run -d -v conf/DataNode.properties:/home/okuyama/conf/DataNode.properties -v $(pwd)/logs:/home/okuyama/logs -v $(pwd)/keymapfile:/home/okuyama/keymapfile mitonize/okuyama
```
