ami                 = "ami-073c8c0760395aab8"
key_name            = "mediawiki"
public_key_path     = "/home/cloud_user/.ssh/mediawiki.pub"
web_instance_type   = "t2.micro"
db_instance_type    = "t2.micro"
aws_profile         = "mediawiki"
user_data           = "file(/files/user-data.sh)"


