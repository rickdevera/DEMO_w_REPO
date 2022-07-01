variable "whitelist" {
  type = list(string)
}

resource "aws_s3_bucket" "prod_tf_course" {
  bucket = "tf-course-rd20200426"
  acl    = "private"

  versioning {
    enabled    = true
    mfa_delete = true
  }


  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = "<master_kms_key_id>"
      }
    }
  }
}

resource "aws_default_vpc" "default" {
}

resource "aws_security_group" "prod_web" {
  name        = "prod_web"
  description = "allow standard http and https ports inbound and all outbound"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
#    cidr_blocks = ["10.0.0.0/24"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
#   cidr_blocks = ["10.0.0.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.whitelist
  }

  tags = {
    "Terraform" = "true"
  }
}

resource "aws_instance" "prod_web" {
  ami           = "ami-0bff305bbe67a4291"
  instance_type = "t2.nano"

  vpc_security_group_ids = [
    aws_security_group.prod_web.id
  ]

  tags = {
    "Terraform" = "true"
  }

  metadata_options {
    http_endpoint = "disabled"
    http_tokens   = "required"
  }
}

resource "aws_eip" "prod_web" {
  instance = aws_instance.prod_web.id

  tags = {
    "Terraform" : "true"
  }
}
resource "aws_s3_bucket_policy" "prod_tf_coursepolicy" {
  bucket = aws_s3_bucket.prod_tf_course.id

  policy = <<POLICY
  {
    "Version": "2012-10-17",
     "Statement": [
     {
        "Sid": "prod_tf_course-restrict-access-to-users-or-roles",
        "Effect": "Allow",
        "Principal": [
         {
            "AWS": [
                "<aws_policy_role_arn>"
                ]
          }
            ],
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::prod_tf_course/*"
      }
      ]
   }
    POLICY
}
