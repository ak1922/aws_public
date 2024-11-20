This project creates a vpc with four subnets, two private and two public. There is also an internet gateway, a nat
gateway, an eip, route table with associations and a Cloudwatch log group for VPC Flow logs.  There is a sample
```terraform.tfvars``` file if you choose to use it. Resource names are generated from the```locals.tags``` block.
To change the ```common_name``` of this project, implement your changes through the ``locals.tf`` file or otherwise.

Terraform resources\
```aws_vpc```\
```aws_subnet```\
```aws_eip```\
```aws_internet_gateway```\
```aws_nat_gateway```\
```aws_route_table```\
```aws_route_table_association```\
```aws_iam_role```\
```aws_iam_role_policy```\
```aws_cloudwatch_log_group```\
```aws_flow_log```

Good Luck!
