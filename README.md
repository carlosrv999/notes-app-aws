# Notes app in aws

## Description

- Runs the Notes web app in AWS using ECS Service as frontend and RDS PostgreSQL as database.

## Instructions

- Create private docker image from this [repo](https://github.com/carlosrv999/nextjs-prisma-CRUD.git) and push to ECR
- Pass ECR container image URL as container_image variable
- Run ```terraform plan``` then ```terraform apply```

## Compatibility

- Requires sed and psql cli v14 (better run on Mac or Linux)
- For Windows, remove **null-resource** from **main.tf** and restore the database manually with the ```database.sql``` script
