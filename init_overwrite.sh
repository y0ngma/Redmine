VARGRANT_SYNC_FOLDER=../VAGRANT_SYNC
if [ -d $VARGRANT_SYNC_FOLDER ]; then
  echo "My vagrant sync folder dir in host: $VARGRANT_SYNC_FOLDER"
else
  echo "Creating my vagrant sync folder: $VARGRANT_SYNC_FOLDER"
  mkdir -p $VARGRANT_SYNC_FOLDER
  mkdir -p $VARGRANT_SYNC_FOLDER/redmine/config
cp ./cpfile/Dockerfile-postgres $VARGRANT_SYNC_FOLDER
cp ./cpfile/docker-compose.yml $VARGRANT_SYNC_FOLDER
cp ./cpfile/configuration.yml $VARGRANT_SYNC_FOLDER/redmine/config
fi