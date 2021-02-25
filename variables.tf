variable "ami" {}
variable "key_name" {}
variable "public_key_path" {}
variable "web_instance_type" {}
variable "db_instance_type" {}
variable "aws_profile" {}
data "template_file" "user_data" {
  template = file("files/user-data.sh")
}

