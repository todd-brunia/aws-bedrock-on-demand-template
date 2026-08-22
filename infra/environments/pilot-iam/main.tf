data "terraform_remote_state" "bedrock" {
  backend = "s3"
  config = {
    bucket       = var.state_bucket_name
    key          = "pilot-bedrock/terraform.tfstate"
    region       = var.aws_region
    encrypt      = true
    use_lockfile = true
  }
}

data "aws_iam_policy_document" "runtime_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = tolist(var.trusted_workload_role_arns)
    }
  }
}

resource "aws_iam_role" "runtime" {
  name               = "bedrock-on-demand-pilot-runtime"
  assume_role_policy = data.aws_iam_policy_document.runtime_trust.json
  tags               = local.tags
}

data "aws_iam_policy_document" "runtime" {
  statement {
    sid       = "InvokeOnlyApprovedInferenceProfiles"
    actions   = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
    resources = values(data.terraform_remote_state.bedrock.outputs.inference_profile_arns)
  }
  statement {
    sid       = "ReadApprovedCatalog"
    actions   = ["bedrock:GetInferenceProfile", "bedrock:ListInferenceProfiles"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "runtime" {
  name   = "approved-bedrock-inference"
  role   = aws_iam_role.runtime.id
  policy = data.aws_iam_policy_document.runtime.json
}
