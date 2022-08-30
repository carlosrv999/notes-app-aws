output "task_execution_role_arn" {
  value = aws_iam_role.default.arn
}

output "task_execution_role_name" {
  value = aws_iam_role.default.name
}
