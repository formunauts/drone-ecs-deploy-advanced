# ECS deploy plugin for drone.io

[https://hub.docker.com/r/formunauts/drone-ecs-deploy-advanced/](https://hub.docker.com/r/formunauts/drone-ecs-deploy-advanced/)

This plugin allows updating an ECS service in a very specific way.

Based on https://github.com/joshdvir/drone-ecs-deploy and https://github.com/silinternational/ecs-deploy.

## Usage

You will need to set the `cluster`, `image`, `region` and `role` properties in
your drone config and additionally the `services` (to update ECS services),
`tasks` (for running one-off tasks), `predeploy_tasks` (for running tasks before
updating services) and `exec_commands` (for executing commands in the old
containers before deployment) properties.

Each entry in `services` will change the service with the same name, changing
the image in the task definition and update the service with the new definition.

If `tasks` or `predeploy_tasks` is set, it's also required to provide the
`task_definition` property, as it can't be determined automatically (like with
services). Each line is equivalent to one executed task and `CMD` (in Docker)
will be set to this value. For `tasks` it's not guaranteed, that the tasks will
execute in order, and they will be triggered simultaneously with the updating of
the services. Tasks specified via `predeploy_tasks`, on the other hand, _will_
be run sequentially, and an unsuccessful exit code will lead to aborting the
deployment.

If `exec_commands` are set it's also required to provide an `exec_service` where
they will be executed. This can be used to specify commands that need to run
sequentially and complete successfully before any `services` are deployed or
`tasks` or `predeploy_tasks` are started.

```yaml
steps:
  ...
  image: formunauts/drone-ecs-deploy-advanced
  settings:
    cluster: <cluster-name>
    image: <image-name>
    region: <aws-region>
    role: <role-arn>
    exec_service:
      - service-a
    exec_commands:
      - ./prepare.sh
    task_definition: <task-definition-name>
    predeploy_tasks:
      - ./predeploy.sh
    services:
      - service-a
      - service-b
      - service-c
    tasks:
      - ./custom_command.sh
  ...
```

## Release Process

To build a new docker image of `drone-ecs-deploy-advanced` and push it to the
Docker hub, use the following commands:

```sh
VERSION=1.2.0
docker build -t "formunauts/drone-ecs-deploy-advanced:$VERSION" .
docker push "formunauts/drone-ecs-deploy-advanced:$VERSION"
```

## License

See [LICENSE](LICENSE) for full details.

```
Copyright (C) 2024 Formunauts GmbH

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
```
