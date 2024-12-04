aws_region    = "us-west-2"
operator_cidr = "192.168.1.1/32"
environment   = "example"
key_name      = "example"
ecs           = { enabled = true }
ec2           = { enabled = true }
domain        = "verb-adjective-noun.com"
cert_arn      = "arn:aws:acm:us-west-2:211125411413:certificate/c3113d3d-38d1-4ea9-b519-af4a17483b3e"
db            = { rds_instance = true, rds_cluster = true }
s3_cert_arn   = "arn:aws:acm:us-east-1:211125411413:certificate/44fd8100-ce42-44c9-ae18-c26f25b4333a"
