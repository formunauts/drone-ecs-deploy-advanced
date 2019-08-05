# ECS deploy plugin for drone.io

[https://hub.docker.com/r/formunauts/drone-ecs-deploy-advanced/](https://hub.docker.com/r/formunauts/drone-ecs-deploy-advanced/)

This plugin allows updating an ECS service in a very specific way.

## Usage

You will need to set the `cluster`, `image`, `region` and `role` properties in
your drone config and additionally the `services` (to update ECS services) and
`tasks` (for running one-off tasks) properties.

Each entry in `services` will change the service with the same name, changing
the image in the task definition and update the service with the new definition.

If `tasks` is set, it's also required to provide the `task_definition` property,
as it can't be determined automatically (like with services).

Each line is equivalent to one executed task and `CMD` (in Docker) will be set
to this value. It's not guaranteed, that the tasks will execute in order.

```yaml
steps:
  ...
  image: formunauts/drone-ecs-deploy-advanced
  settings:
    cluster: <cluster-name>
    image: <image-name>
    region: <aws-region>
    role: <role-arn>
    services:
      - service-a
      - service-b
      - service-c
    task_definition: <task-definition-name>
    tasks:
      - ./custom_command.sh
  ...
```
