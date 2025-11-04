docker start registry

docker buildx build \
  --platform linux/amd64\
  -t host.docker.internal:5000/zarf-vite-template:latest \
  . \
  --push

zarf package create deployment/.
zarf package remove zarf-vite-template --confirm
zarf package deploy zarf-package-zarf-vite-template-amd64-latest.tar.zst --confirm