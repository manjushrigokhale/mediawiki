output "public_ip" {
  description = "instance Ip address"
  value = aws_instance.media_web_1.public_ip
}
output "DB_Host" {
  description = "db instance dns"
  value = "localhost"
}

output "DB_Username" {
  description = "database user name"
  value = "admin"
}
output "Database_Name" {
  description = "database name"
  value = "wikidatabase"
} 
output "DB_Admin_Password" {
  description = "database admin user password"
  value = "admin.mediawiki"
} 
