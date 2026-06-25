# ---------------------------------------------------------------------------
# CodeArtifact — the single controlled source for every npm and pip dependency
# the build consumes (AGENTS.md §1/§2, securing-supply-chain control #1). The
# build authenticates with a short-lived token and pulls ALL deps THROUGH this
# domain, so there are no direct public-registry pulls and every package is
# proxied, recorded, and curatable.
#
# Topology (a repo may have an external connection OR upstreams, never both):
#   npm-store  --(external)-->  public:npmjs      pip uses pypi-store below
#   pypi-store --(external)-->  public:pypi
#   npm        --(upstream)-->  npm-store         <- build points npm here
#   pip        --(upstream)-->  pypi-store        <- build points pip here
# ---------------------------------------------------------------------------

locals {
  # domain_name is optional; default it to the project name.
  domain_name = coalesce(var.domain_name, var.project)
}

# Domain groups the repos and owns the shared asset store. We rely on the
# default AWS-managed key (aws/codeartifact) for encryption — no custom KMS.
# Trade-off: a customer-managed KMS key would give key-rotation control and
# tighter audit/grant scoping, but it adds key management overhead that this
# lab does not need. Set `encryption_key` later to harden for production.
resource "aws_codeartifact_domain" "this" {
  domain = local.domain_name

  tags = { Name = local.domain_name }
}

# ---- Store repos: hold the public external connections only ----
resource "aws_codeartifact_repository" "npm_store" {
  repository = "npm-store"
  domain     = aws_codeartifact_domain.this.domain

  external_connections {
    external_connection_name = "public:npmjs"
  }

  tags = { Name = "${var.project}-npm-store" }
}

resource "aws_codeartifact_repository" "pypi_store" {
  repository = "pypi-store"
  domain     = aws_codeartifact_domain.this.domain

  external_connections {
    external_connection_name = "public:pypi"
  }

  tags = { Name = "${var.project}-pypi-store" }
}

# ---- App repos: hold the upstream to the matching store repo ----
# The upstream reference creates an implicit dependency, guaranteeing the store
# repo exists first. An app repo must NOT also declare external_connections.
resource "aws_codeartifact_repository" "npm" {
  repository = "npm"
  domain     = aws_codeartifact_domain.this.domain

  upstream {
    repository_name = aws_codeartifact_repository.npm_store.repository
  }

  tags = { Name = "${var.project}-npm" }
}

resource "aws_codeartifact_repository" "pip" {
  repository = "pip"
  domain     = aws_codeartifact_domain.this.domain

  upstream {
    repository_name = aws_codeartifact_repository.pypi_store.repository
  }

  tags = { Name = "${var.project}-pip" }
}
