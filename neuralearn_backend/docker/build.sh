REGISTRY_ID=crp38865vs41akamblti
TAG=cr.yandex/$REGISTRY_ID/backend:latest

mkdir ./build
cp -r ../src/ ./build/src
cp ../package.json ./build
cp ../package-lock.json ./build

cat ../../infra/data/sa-registry.secret.json | docker login --username json_key --password-stdin cr.yandex
docker build . -t $TAG -f ./Dockerfile.prod
docker push $TAG

rm -r ./build