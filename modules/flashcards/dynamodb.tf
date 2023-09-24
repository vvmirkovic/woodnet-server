resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = var.name
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "WordId"
  range_key      = "WordId"

  attribute {
    name = "WordId"
    type = "N"
  }
}