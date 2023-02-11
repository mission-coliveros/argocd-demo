env_name          = "dev"
aws_region        = "us-west-2"
vpc_subnet_prefix = "10.11"

custom_namespaces = [
  {
    name : "mission-api-dev-01"
    labels : { "app" : "mission-api" }
  },
  {
    name : "mission-api-dev-02"
    labels : {
      "app" : "mission-api",
    }
  }
]