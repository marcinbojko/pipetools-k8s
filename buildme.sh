#!/bin/bash
release=$(grep "LABEL RELEASE" Dockerfile|awk '{print $2}'|cut -d\" -f2)
version=$(grep "LABEL VERSION" Dockerfile|awk '{print $2}'|cut -d\" -f2)
maintainer=$(grep "LABEL MAINTAINER" Dockerfile|awk '{print $2}'|cut -d\" -f2)
coverage="./coverage.txt"

echo Version: "$version" found
echo Release: "$release" found
echo maintainer: "$maintainer" found
if [ ! -z "$version" ] && [ ! -z "$release" ]; then
  docker build -t "$release":"$version" .
  build_status=$?
  docker container prune --force
  # let's tag latest
  docker tag "$release":"$version" "$release":latest
else
  echo "No version or release found, exiting"
  exit 1
fi
# coverage
if [ "$build_status" == 0 ]; then
  echo "Docker build succeed"
  rm -rf dive.log||true
  rm -rf ./*.txt|true
  date > "$coverage"
  docker run -it "$release:$version" helm version -c >>"$coverage"
  docker run -it "$release:$version" kubectl version --client=true >>"$coverage"
  trivy --output coverage-"$version"_trivy.txt "$release":"$version"
  dive --ci "$release":"$version" > coverage-"$version"_dive.txt
  sed -i 's/\x1B\[[0-9;]*[JKmsu]//g' coverage-"$version"_dive.txt||true
  dockle -f json -o coverage-"$version"_dockle.txt "$release":"$version"
else
 echo "Docker build failed, exiting now"
fi
