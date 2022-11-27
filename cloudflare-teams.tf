resource "cloudflare_teams_account" "homenet" {
  account_id           = var.account_id

  activity_log_enabled = true
  tls_decrypt_enabled  = true

  antivirus {
    enabled_download_phase = true
    enabled_upload_phase   = false
    fail_closed            = false
  }

  block_page {
    enabled = false
  }

  logging {
    redact_pii = true

    settings_by_rule_type {
      dns {
        log_all    = true
        log_blocks = false
      }

      http {
        log_all    = true
        log_blocks = false
      }

      l4 {
        log_all    = true
        log_blocks = false
      }
    }
  }

  proxy {
    tcp = true
    udp = true
  }
}