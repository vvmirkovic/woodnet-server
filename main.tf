terraform {
  backend "s3" {
    bucket = "state-414057778078"
    key    = "woodnet/home"
    region = "us-east-1"
  }
}
