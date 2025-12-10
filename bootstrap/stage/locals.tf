locals {
  # users in these lists are granted AWS access (pending retirement of all AWS stuff)
  iam_admin_users     = ["rsalmond", "ianedington", "verdird", "mattw"]
  iam_eks_users       = ["pnovikov"]
  environment         = "stage"
  gcp_org_id          = 267619224561
  gcp_billing_account = "019C4D-E56387-A59CAF"
  # every user in this list will be granted dev access
  dev_users = ["tdresser@gmail.com"]
}
