# ArkCase Deployment Base Image

This Project produces ArkCase Base Deployment Image. This image contains nothing but the basic tools that will be required by sub-images which will actually contain the deployment artifacts.

## How to build your local copy:

docker build -t public.ecr.aws/arkcase/deploy:latest .
