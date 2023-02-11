env_name          = "prod"
aws_region        = "us-west-2"
vpc_subnet_prefix = "10.21"

custom_namespaces = [
  {
    name : "misison-api-prod"
    labels : { "app" : "mission-api" }
  }
]