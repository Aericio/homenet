locals {
  # Parse the file and create a list, one item per line
  domain_list = split("\n", file("${path.module}/resources/hosts.txt"))

  # Cleans up the domain list.
  # -> Removes empty lines
  # -> Removes comments
  # -> Removes localhost entries
  # -> Removes the 127.0.0.1 prefix
  domain_list_clean = [for x in local.domain_list : substr(x, 10, -1) if x != "" && substr(x, 0, 1) != "#" && substr(x, -9, -1) != "localhost"]

  # Use chunklist to split a list into fixed-size chunks
  aggregated_lists = chunklist(local.domain_list_clean, 1000)
}

resource "cloudflare_teams_list" "adaway_domain_lists" {
  account_id = var.account_id

  for_each = {
  for i in range(0, length(local.aggregated_lists)) :
  i => element(local.aggregated_lists, i)
  }

  name  = "adaway_domain_list_${each.key}"
  type  = "DOMAIN"
  items = each.value
}