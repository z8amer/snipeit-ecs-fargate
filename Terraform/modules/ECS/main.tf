#Group Container/s together
resource "aws_ecs_cluster" "core_cluster" {
  name = "${var.project_name}-cluster"

  setting {
    name  = var.ecs_setting_name
    value = var.ecs_setting_value
  }
}

#Container application configuration
resource "aws_ecs_task_definition" "app_task" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc" # Fargate strictly requires awsvpc networking mode [INDEX]
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu                        # 0.25 vCPU (Sandbox friendly)
  memory                   = var.task_memory                     # 512MB RAM
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn # The permissions guard

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.existing_ecr_url # <--- CONSUMES YOUR EXISTING ECR URL STRING!
      essential = true
      portMappings = [
        {
          containerPort = var.container_port # The port your app code inside the container listens on
          hostPort      = var.host_port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_log_group.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = var.log_prefix
        }
      }
    }
  ])
}

#Container service configuration
resource "aws_ecs_service" "app_service" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.core_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = var.service_desired_count
  launch_type     = "FARGATE"

  #Network placement configurations
  network_configuration {
    subnets          = var.private_subnet_cidrs
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  #Links Load Balancer to container
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
}

#Container Security Group
resource "aws_security_group" "ecs_sg" {
  name        = "${var.project_name}-ecs-tasks-sg"
  description = "Isolate containers and restrict inbound traffic to the ALB only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow traffic ONLY if it comes through public load balancer"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    description = "Allow containers to talk out to the internet to download packages/updates"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ecs-tasks-sg"
  }
}

#ECS Task execution IAM Role
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.project_name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com" # The exact AWS server principal allowed to assume this role
        }
      }
    ]
  })
}

#Attach permissions to IAM role
resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#Cloudwatch log group
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/${var.project_name}-logs"
  retention_in_days = var.log_retention_days
  tags = {
    Name = "${var.project_name}-log-group"
  }
}
