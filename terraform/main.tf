resource "aws_ecr_repository" "backend" {
  name = "${var.project_name}-backend"
}

resource "aws_ecr_repository" "worker" {
  name = "${var.project_name}-worker"
}

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/devops-assignment"
  retention_in_days = 7
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "devops-assignment-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "devops-assignment-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "backend"
      image = "828562155228.dkr.ecr.ap-south-1.amazonaws.com/devops-assignment-backend:latest"

      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/devops-assignment"
          awslogs-region        = "ap-south-1"
          awslogs-stream-prefix = "backend"
        }
      }
    }
  ])
}

resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "subnet_a" {
  availability_zone = "ap-south-1a"
}

resource "aws_default_subnet" "subnet_b" {
  availability_zone = "ap-south-1b"
}

resource "aws_ecs_service" "backend_service" {
  name            = "devops-assignment-backend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  launch_type     = "FARGATE"

  desired_count = 1

  network_configuration {
    subnets = [
      aws_default_subnet.subnet_a.id,
      aws_default_subnet.subnet_b.id
    ]

    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "devops-assignment-ecs-sg"
  description = "Allow HTTP access to ECS"

  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
