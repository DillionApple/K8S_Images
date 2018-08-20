#!/bin/bash

K8S_VERSION=1.11.2
DOCKER_REGISTRY_URL=dillionmango/k8s_images

images=$(kubeadm config --kubernetes-version $K8S_VERSION images list)

function generate_docker_files() {
    for image in $images
    do
	full_name=$(echo $image | awk -F/ '{ print $2 }')
	image_name=$(echo $full_name | awk -F: '{ print $1 }')
	tag_name=$(echo $full_name | awk -F: '{ print $2 }')
	folder_name=$image_name-$tag_name
	echo $folder_name
	mkdir -p $folder_name
	echo "from $image" > $folder_name/Dockerfile
	echo "MAINTAINER Dillion <DillionMango@gmail.com>" >> $folder_name/Dockerfile
    done
}

function pull_images() {
    for image in $images
    do
	full_name=$(echo $image | awk -F/ '{ print $2 }')
	image_name=$(echo $full_name | awk -F: '{ print $1 }')
	tag_name=$(echo $full_name | awk -F: '{ print $2 }')
	folder_name=$image_name-$tag_name
	docker pull $DOCKER_REGISTRY_URL:$folder_name
	docker tag $DOCKER_REGISTRY_URL:$folder_name $image
	docker rmi $DOCKER_REGISTRY_URL:$folder_name
    done
}


case $1 in
    generate_docker_files)
	generate_docker_files
	;;
    pull_images)
	pull_images
	;;
    *)
	echo usage: generate_docker_files/pull_images
esac

