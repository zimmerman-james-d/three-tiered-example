resource "aws_iam_role" "iam-role" {
  name = var.name
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : var.service
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "existing_attachment_policy" {
  for_each   = toset(var.policies)
  role       = aws_iam_role.iam-role.name
  policy_arn = each.key
}
