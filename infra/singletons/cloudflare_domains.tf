resource "cloudflare_zone" "gpo_ca" {
  account_id = data.sops_file.secrets.data["cloudflare_account_id"]
  zone       = "gpo.ca"
}

resource "cloudflare_record" "gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "gpo.ca"
  content = "143.244.200.166"
  type    = "A"
  ttl     = 300
  proxied = true
}

resource "cloudflare_record" "secure_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "secure.gpo.ca"
  content = "192.124.249.179"
  type    = "A"
  ttl     = 300
  proxied = true
}

resource "cloudflare_record" "staging_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "staging.gpo.ca"
  content = "137.184.128.54"
  type    = "A"
  ttl     = 300
  proxied = true
}

resource "cloudflare_record" "dev_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "dev.gpo.ca"
  content = "134.122.120.190"
  type    = "A"
  ttl     = 300
  proxied = true
}

resource "cloudflare_record" "staging_secure_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "staging.secure.gpo.ca"
  content = "137.184.128.54"
  type    = "A"
  ttl     = 300
  proxied = true
}

resource "cloudflare_record" "o1_list_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "o1.list.gpo.ca"
  content = "159.183.192.198"
  type    = "A"
  ttl     = 300
}

resource "cloudflare_record" "dev_secure_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "dev.secure.gpo.ca"
  content = "134.122.120.190"
  type    = "A"
  ttl     = 300
}

resource "cloudflare_record" "mail_dev_secure_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "mail.dev.secure.gpo.ca"
  content = "134.122.120.190"
  type    = "A"
  ttl     = 300
}

resource "cloudflare_record" "return_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "return.gpo.ca"
  content = "u28200265.wl016.sendgrid.net"
  type    = "CNAME"
  ttl     = 300
}

resource "cloudflare_record" "sgr__domainkey_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "sgr._domainkey.gpo.ca"
  content = "sgr.domainkey.u28200265.wl016.sendgrid.net"
  type    = "CNAME"
  ttl     = 300
}

resource "cloudflare_record" "sgr2__domainkey_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "sgr2._domainkey.gpo.ca"
  content = "sgr2.domainkey.u28200265.wl016.sendgrid.net"
  type    = "CNAME"
  ttl     = 300
}

resource "cloudflare_record" "emailing_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "emailing.gpo.ca"
  content = "sendgrid.net"
  type    = "CNAME"
  ttl     = 300
}

resource "cloudflare_record" "_28200265_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "28200265.gpo.ca"
  content = "sendgrid.net"
  type    = "CNAME"
  ttl     = 300
}

resource "cloudflare_record" "www_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "www.gpo.ca"
  content = "gpo.ca"
  type    = "CNAME"
  ttl     = 300
}

resource "cloudflare_record" "agmsurvey_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "agmsurvey.gpo.ca"
  content = "www.surveymonkey.com.opts-slash.r.opts-slash.8x8j6s2.redirect.center"
  type    = "CNAME"
  ttl     = 300
}

resource "cloudflare_record" "e_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "e.gpo.ca"
  content = "u28200265.wl016.sendgrid.net"
  type    = "CNAME"
  ttl     = 300
}

resource "cloudflare_record" "spark_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "spark.gpo.ca"
  content = "sparkpostmail.com"
  type    = "CNAME"
  ttl     = 300
}

resource "cloudflare_record" "strong1__domainkey_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "strong1._domainkey.gpo.ca"
  content = "strong1._domainkey.helpscout.net"
  type    = "CNAME"
  ttl     = 300
}

resource "cloudflare_record" "strong2__domainkey_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "strong2._domainkey.gpo.ca"
  content = "strong2._domainkey.helpscout.net"
  type    = "CNAME"
  ttl     = 300
}

resource "cloudflare_record" "e2_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "e2.gpo.ca"
  content = "u28235135.wl136.sendgrid.net"
  type    = "CNAME"
  ttl     = 300
}

resource "cloudflare_record" "s1__domainkey_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "s1._domainkey.gpo.ca"
  content = "s1.domainkey.u28235135.wl136.sendgrid.net"
  type    = "CNAME"
  ttl     = 300
}

resource "cloudflare_record" "s2__domainkey_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "s2._domainkey.gpo.ca"
  content = "s2.domainkey.u28235135.wl136.sendgrid.net"
  type    = "CNAME"
  ttl     = 300
}

resource "cloudflare_record" "_28264590_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "28264590.gpo.ca"
  content = "sendgrid.net"
  type    = "CNAME"
  ttl     = 300
}

resource "cloudflare_record" "e1_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "e1.gpo.ca"
  content = "u28264590.wl091.sendgrid.net"
  type    = "CNAME"
  ttl     = 300
}

resource "cloudflare_record" "sg__domainkey_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "sg._domainkey.gpo.ca"
  content = "sg.domainkey.u28264590.wl091.sendgrid.net"
  type    = "CNAME"
  ttl     = 300
}

resource "cloudflare_record" "sg2__domainkey_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "sg2._domainkey.gpo.ca"
  content = "sg2.domainkey.u28264590.wl091.sendgrid.net"
  type    = "CNAME"
  ttl     = 300
}

resource "cloudflare_record" "mx_aspmx_gpo_ca" {
  zone_id  = cloudflare_zone.gpo_ca.id
  name     = "gpo.ca"
  content  = "aspmx.l.google.com"
  priority = 1
  type     = "MX"
  ttl      = 300
}

resource "cloudflare_record" "mx_alt1_gpo_ca" {
  zone_id  = cloudflare_zone.gpo_ca.id
  name     = "gpo.ca"
  content  = "alt1.aspmx.l.google.com"
  priority = 5
  type     = "MX"
  ttl      = 300
}

resource "cloudflare_record" "mx_alt2_gpo_ca" {
  zone_id  = cloudflare_zone.gpo_ca.id
  name     = "gpo.ca"
  content  = "alt2.aspmx.l.google.com"
  priority = 5
  type     = "MX"
  ttl      = 300
}

resource "cloudflare_record" "mx_aspmx2_gpo_ca" {
  zone_id  = cloudflare_zone.gpo_ca.id
  name     = "gpo.ca"
  content  = "aspmx2.googlemail.com"
  priority = 10
  type     = "MX"
  ttl      = 300
}

resource "cloudflare_record" "mx_aspmx3_gpo_ca" {
  zone_id  = cloudflare_zone.gpo_ca.id
  name     = "gpo.ca"
  content  = "aspmx3.googlemail.com"
  priority = 10
  type     = "MX"
  ttl      = 300
}

resource "cloudflare_record" "web_e_gpo_ca" {
  zone_id  = cloudflare_zone.gpo_ca.id
  name     = "web.e.gpo.ca"
  content  = "mx.sendgrid.net."
  priority = 1
  type     = "MX"
  ttl      = 300
}

resource "cloudflare_record" "spf_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "gpo.ca"
  content = "v=spf1 ip4:168.245.17.225 include:_spf.google.com include:helpscoutemail.com ~all"
  type    = "TXT"
  ttl     = 300
}

resource "cloudflare_record" "mail__domainkey_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "mail._domainkey.gpo.ca"
  content = "v=DKIM1; g=*; k=rsa; t=y; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDL/yJ8RTaaLS1iKCySH7L+5XsSdz5uwWZVHjtWYOXm/wJU9xI4NmBfVrl7XbTbeQnu7RtL8TCLgmsBE6Ut1KyAlC+mEApKnJ8oDaZMveTkL7+yIa5+qxpO5EaW281nbDq7zfsKtfnT7AEwwQF14PETlAbgh8QCzWEwClulsUNjuQIDAQAB"
  type    = "TXT"
  ttl     = 300
}

resource "cloudflare_record" "google__domainkey_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "google._domainkey.gpo.ca"
  content = "\"v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA7RCyGRi/9IJLNCq4aLbOzZyaTUC4dALTezih8B2AruUzy3+b275/2k/uSRtCR6ZIIq1IV5h1G78s27gbuvNIt8u3JZ1axk/c9RVcshT+vVJHyDRrnu6CMGzCR82Ev7KsJ4aEnCIl5HsxqF3yLY0EH3NoACyS0tt8CzagYhzZMttci2yYZ9iD5v10onEY\" \"xFZf23xhLSqfji0RG88GBiTwVt/YJYPYeP/syPWNIJITC423nBocOTxJ8cxUJV0KasC+nZK68UaUJ6orqoWUM1CylxHxikqGxgRR9NbNdzuN/1AnK+Byf3pcwLHCfIXz9q4P7Hff573dvTNw2tFOeLwpxwIDAQAB\""
  type    = "TXT"
  ttl     = 300
}

resource "cloudflare_record" "scph0219__domainkey_presslist_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "scph0219._domainkey.presslist.gpo.ca"
  content = "v=DKIM1; k=rsa; h=sha256; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDQkfm5YmOi7e6MNJz3ndVw4SfxLO89xd0PyoTzQX2ZviVY1Fx4TMQjOBaKh622IRpteMscBTHHB1aIzSz5QncCH8qxP8pB6toBmi9DKkEzPF5QQ4d8GcqJND2IqhFCsPJAkc6KGLZWFXW9hsuh04W05NXDZmtnu0MfljIDBb/RawIDAQAB"
  type    = "TXT"
  ttl     = 300
}

resource "cloudflare_record" "feb2019__domainkey_lists_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "feb2019._domainkey.lists.gpo.ca"
  content = "v=DKIM1;p=testing123123"
  type    = "TXT"
  ttl     = 300
}

resource "cloudflare_record" "_dmarc_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "_dmarc.gpo.ca"
  content = "v=DMARC1; p=none; rua=mailto:dmarc@gpo.ca"
  type    = "TXT"
  ttl     = 300
}

resource "cloudflare_record" "spf_web_e_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "web.e.gpo.ca"
  content = "v=spf1 include:sendgrid.net ~all"
  type    = "TXT"
  ttl     = 300
}

resource "cloudflare_record" "sgw__domainkey_e_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "sgw._domainkey.e.gpo.ca"
  content = "k=rsa; t=s; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC/jEPkWK1BY2nPk8kB8HT0mR/wA+lSjLQ3MWDKgg/AEsz+vTB7ig5k/Jn7Q2UEh9Y+LGDb3+IK0k56u9fSpX0zHYpc9U2gOi84irplAbf39oMkMq7041SfreV6ENLekLmi0I8wqXiqd+IQpNb7+zduUvLRUsCa8LNFc5hMgewVWwIDAQAB"
  type    = "TXT"
  ttl     = 300
}

resource "cloudflare_record" "scph1018__domainkey_spark_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "scph1018._domainkey.spark.gpo.ca"
  content = "v=DKIM1; k=rsa; h=sha256; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDVgAwRmison7hL0ECmTLrkJx8Hl6X1KPypmT8PJLsbCW2DwdFN4cz3spMNh54xfgaiCe1lBx95EM+38Jy8kdMaoPZoIMfkf17cPp9kF0VNTwkG31oF7ccUGuj8iyLmOkHCP79yIYjM0zQsMtGxwl6R2n2F+5mE7JPYFnqQl+PBCQIDAQAB"
  type    = "TXT"
  ttl     = 300
}

resource "cloudflare_record" "scph1018__domainkey_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "scph1018._domainkey.gpo.ca"
  content = "v=DKIM1; k=rsa; h=sha256; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDHoL0LR9IjrfzaV8bH3gmy4R3cNpjqubv9axTGZR/IG5KbuHxrnpVmRT0+cHsky/xq1s/6XyDciAmXFlE154RcUrLnqWT9kKh30O0a4FsSc8Ur3SzAsh/6CPFKVSxSznM7c6bqSkTNMTB8XuZlp3tNiZ0pFXkUdawFuFOcVCKFEQIDAQAB"
  type    = "TXT"
  ttl     = 300
}

resource "cloudflare_record" "mar2019__domainkey_lists_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "mar2019._domainkey.lists.gpo.ca"
  content = "v=DKIM1;p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDseumw0gBlnJqXmXK14jNzsq73xyCP6fW6eqzs9Z4CdLvvkEzhCX1nL7D9AXTFFgjqw8J4185HAHkzLuPRJ3QqOZWiqOOXmzOG6fHHlxfARp4SHpUQdXaUBMjbjDMxznuMyTFtAqepS5PwHhwmB17ezToB9BUDae7y/fgKwFK79QIDAQAB"
  type    = "TXT"
  ttl     = 300
}

resource "cloudflare_record" "list_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "list.gpo.ca"
  content = "google-site-verification=-zgog0QI7kpVmqeRgdKcz5u1M8tTdgB2QRE1Xs-eCJo"
  type    = "TXT"
  ttl     = 300
}

resource "cloudflare_record" "google_secure_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "secure.gpo.ca"
  content = "google-site-verification=omPDG1sAStc3PcgGLKiMc9yLmhuL59BvUF0juSdBDxU"
  type    = "TXT"
  ttl     = 300
}

resource "cloudflare_record" "facebook_secure_gpo_ca" {
  zone_id = cloudflare_zone.gpo_ca.id
  name    = "secure.gpo.ca"
  content = "facebook-domain-verification=ma7wgbljzgdw67csxyip3ce1imh301"
  type    = "TXT"
  ttl     = 300
}
