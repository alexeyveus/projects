[
    {
      "name": "${name}",
      "image": "${container_image}@${digest}",
      "cpu": ${cpu},
      "memory": ${memory},
      "memoryReservation": ${memory},
      "environment": [
        { 
          "name" : "JAVA_OPTS", 
          "value" : "-Djenkins.install.runSetupWizard=false -Dcasc.merge.strategy=override" 
        },
        {
          "name": "JENKINS_HOME",
          "value": "${jenkinsHome}"            
        },
        {
          "name": "CASC_JENKINS_CONFIG",
          "value": "${jenkinsHome}/jenkins.yaml"            
        }
      ],
      "linuxParameters": {
          "initProcessEnabled": true
      },
      "essential": true,
      "mountPoints": [
        {
          "containerPath": "/var/jenkins_home",
          "sourceVolume": "${source_volume}"
        }
      ],
      "portMappings": [
        {
          "containerPort": ${jenkins_controller_port}
        },
        {
          "containerPort": ${jnlp_port}
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${log_group}",
            "awslogs-region": "${region}",
            "awslogs-stream-prefix": "controller"
        }
      }
    }
]
  