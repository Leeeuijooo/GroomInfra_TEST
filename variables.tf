# 리전
variable "region" {
    description = "Groom Region"
    type = string
    default = "ap-northeast-2"
}
variable "eks_name" {
    description = "Groom EKS"
    type = string
    default = "eks_name"
}
variable "azs" {
    description = "Groom AZS"
    default = ["ap-northeast-2a","ap-northeast-2c"]
}
variable "db_password" {
  # password 추가
  default = "dmlwn3232"
  description = "RDS root user password"
  sensitive   = true
}
