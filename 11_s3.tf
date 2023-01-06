resource "aws_s3_bucket" "log" {
  // bucket = var.bucket // bucket naming rule에서 _ 허용 안됨.
  for_each = local.s3
  bucket   = "s3-${local.default_tag}-${each.key}"
  #bucket   = "s3-${local.default_tag}-${each.value.bucket_name}-${var.bucket_serial}" // 전세계 uniq한 값으로 설정
  tags = {
    Name = "s3-${local.default_tag}-${each.key}"
  }
}

#resource "aws_s3_object" "folder" {
#  for_each = { for k, v in local.folder_per_bucket : v.key => v }
#  bucket   = each.value.bucket_id
#  key      = each.value.folders
#}

// Owner gets FULL_CONTROL. No one else has access rights (default).
resource "aws_s3_bucket_acl" "log" {
  for_each = local.s3
  bucket   = aws_s3_bucket.log[each.key].id
  acl      = lookup(each.value, "acl", var.acl)
}

// 버킷 버전 관리
resource "aws_s3_bucket_versioning" "log" {
  for_each = local.s3
  bucket   = aws_s3_bucket.log[each.key].id

  versioning_configuration {
    status = lookup(each.value, "version_enable", var.version_enable)
  }
}

// 해당 버킷에 허용하는 룰. GET, PUT, POST만 넣어줌
resource "aws_s3_bucket_cors_configuration" "log" {
  for_each = local.s3
  bucket   = aws_s3_bucket.log[each.key].id

  cors_rule {
    allowed_headers = lookup(each.value, "allowed_headers", var.allowed_headers)
    allowed_methods = lookup(each.value, "allowed_methods", var.allowed_methods)
    allowed_origins = lookup(each.value, "allowed_origins", var.allowed_origins)
    max_age_seconds = lookup(each.value, "max_age_seconds", var.max_age_seconds)
  }
}

# vpc와 s3 연동을 위해 endpoint 설정
resource "aws_vpc_endpoint" "s3" {
  depends_on   = [aws_s3_bucket.log]
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_id       = aws_vpc.this.id

  tags = {
    Name = "ep-s3-vpc-${local.default_tag}"
  }
}


# resource "aws_s3_bucket_public_access_block" "bucket" {
#   bucket = aws_s3_bucket.bucket.id

#   block_public_acls   = true
#   block_public_policy = true
# }


# resource "aws_cloudfront_origin_access_identity" "OAI" {
# }

# data "aws_iam_policy_document" "s3_policy" {
#   statement {
#     actions   = ["s3:GetObject"]
#     resources = ["${aws_s3_bucket.bucket.arn}/*"]

#     principals {
#       type        = "AWS"
#       identifiers = [aws_cloudfront_origin_access_identity.OAI.iam_arn] // cloudfront.tf 파일에서 생성함
#     }
#   }
# }

# resource "aws_s3_bucket_policy" "bucket" {
#   bucket = aws_s3_bucket.bucket.id
#   policy = data.aws_iam_policy_document.s3_policy.json
# }
