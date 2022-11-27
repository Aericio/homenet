resource "cloudflare_teams_rule" "security_risks" {
  account_id = var.account_id

  name        = "Security Risks"
  description = "Block requests for general security risks"

  enabled    = true
  precedence = 10

  action  = "block"
  filters = ["dns"]
  traffic = "any(dns.security_category[*] in {178 80 83 176 175 117 131 134 151 153 68}) and any(dns.content_category[*] in {99 85 87 128 170})"
  // https://developers.cloudflare.com/cloudflare-one/policies/filtering/domain-categories/

  rule_settings {
    block_page_enabled = true
  }
}

locals {
  # Iterate through each adaway_domain_list resource and extract its ID
  adaway_domain_lists = [for k, v in cloudflare_teams_list.adaway_domain_lists : v.id]

  # Format the values: remove dashes and prepend $
  adaway_domain_lists_formatted = [for v in local.adaway_domain_lists : format("$%s", replace(v, "-", ""))]

  # Create filters to use in the policy
  adaway_ad_filters = formatlist("any(dns.domains[*] in %s)", local.adaway_domain_lists_formatted)
  adaway_ad_filter  = join(" or ", local.adaway_ad_filters)
}

resource "cloudflare_teams_rule" "block_ads" {
  account_id = var.account_id

  name        = "Block Ads"
  description = "Block request to advertisement domains"

  enabled    = true
  precedence = 11

  # Block domain belonging to lists (defined below)
  filters = ["dns"]
  action  = "block"
  traffic = local.adaway_ad_filter

  rule_settings {
    block_page_enabled = false
  }
}
