resource "aws_instance" "example" {
  ami = "ami-00eb20669e0990cb4"
  instance_type = "t2.micro"

  tags {
    Name = "test-import"
  }
}

# terraform init
# terraform import aws_instance.example <instance_id>
