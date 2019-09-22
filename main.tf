resource "aws_storagegateway_gateway" "gateway" {
  gateway_ip_address = var.gateway_ip_address
  gateway_name       = var.gateway_name
  gateway_timezone   = var.gateway_timezone
  gateway_type       = "FILE_S3"
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "aws_storagegateway_nfs_file_share" "nfs" {
  client_list  = var.nfs_client_list
  gateway_arn  = aws_storagegateway_gateway.gateway.arn
  location_arn = aws_s3_bucket.bucket.arn
  role_arn     = aws_iam_role.gateway.arn
}

data "aws_iam_policy_document" "storagegateway" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["storagegateway.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "s3-bucket-access" {
  statement {
    actions = [
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketLocation",
      "s3:GetBucketVersioning",
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:ListBucketMultipartUploads"
    ]

    resources = [
      aws_s3_bucket.bucket.arn
    ]
  }

  statement {
    actions = [
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketLocation",
      "s3:GetBucketVersioning",
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:ListBucketMultipartUploads"
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3-bucket-access" {
  policy = data.aws_iam_policy_document.s3-bucket-access.json
}

resource "aws_iam_role" "gateway" {
  name               = "${var.gateway_name}-role"
  assume_role_policy = data.aws_iam_policy_document.storagegateway.json
}

resource "aws_iam_role_policy_attachment" "gateway-attach" {
  role       = aws_iam_role.gateway.name
  policy_arn = aws_iam_policy.s3-bucket-access.arn
}
