# Niks3 on Cloudflare Containers

This directory deploys a single Niks3 server behind a Cloudflare Worker. The
server coordinates uploads, signs narinfo files, and records cache references in
Neon. Nix clients fetch cache objects directly from the public R2 hostname; they
do not traverse the Worker or Container.

The container image is built from the pinned upstream Niks3 `v1.6.0` release
when Wrangler deploys it. Update `NIKS3_VERSION` in the [Dockerfile](Dockerfile)
and test before upgrading.

## First-time setup

1. Ensure the Cloudflare account is on a Workers Paid plan, which is required
   for Containers. Create a public custom domain for the existing `niks3` R2
   bucket; it is the stable read URL supplied as `NIKS3_CACHE_URL`.
2. Create an R2 S3 API token with **Object Read & Write** scoped only to the
   `niks3` bucket. Its endpoint is
   `https://<account-id>.r2.cloudflarestorage.com` (or the jurisdictional
   equivalent). Use that endpoint as `NIKS3_S3_ENDPOINT`.
3. Create a least-privilege Cloudflare API token for Wrangler, scoped to this
   account's Workers, Durable Objects, and Containers resources. Store it as
   `CLOUDFLARE_API_TOKEN`; store the owning account ID as
   `CLOUDFLARE_ACCOUNT_ID`.
4. Create a dedicated Neon database and role. Its TLS-enabled connection string
   is `NIKS3_DB`.
5. Generate the two Niks3 secrets locally, then store their values through
   SecretSpec:

   ```sh
   nix key generate-secret --key-name cache.example.com-1
   openssl rand -hex 32
   ```

   The first output is `NIKS3_SIGN_KEY`; retain its public-key form for Nix
   clients (`nix key convert-secret-to-public`). The random value is
   `NIKS3_API_TOKEN`.
6. Store `NIKS3_OIDC_CONFIG_JSON` — the OIDC provider config that lets
   GitHub Actions authenticate without a static token (see
   [CI integration](#ci-integration) below).

From the repository root, enter the devenv shell, set every declaration in
[secretspec.toml](../../secretspec.toml), then sync and deploy:

```sh
secretspec check --reason "verify Niks3 deployment secrets"
secretspec run --reason "sync Niks3 Worker secrets" -- ./infra/niks3/scripts/sync-secrets
./infra/niks3/scripts/deploy
```

`sync-secrets` copies only Niks3 runtime values into Cloudflare Worker Secrets.
It never uploads the Cloudflare deployment token or account ID. Wrangler will
refuse deployment while any required Worker secret is absent.

## Client configuration

Use the public R2 custom-domain URL as the substituter and trust the public key
derived above:

```nix
nix.settings = {
  substituters = [ "https://cache.example.com" ];
  trusted-public-keys = [ "cache.example.com-1:<public-key>" ];
};
```

Point upload clients at the deployed Worker URL (`https://niks3.<account>
.workers.dev` initially) and authenticate with `NIKS3_API_TOKEN`.

## CI integration

GitHub Actions authenticates via OIDC — no static token in the workflow.
`NIKS3_OIDC_CONFIG_JSON` scopes this down to a specific repository:

```json
{
  "providers": {
    "github": {
      "issuer": "https://token.actions.githubusercontent.com",
      "audience": "https://niks3.<account>.workers.dev",
      "bound_claims": { "repository": ["<owner>/<repo>"] }
    }
  }
}
```

The workflow needs `permissions: id-token: write` and the
[niks3-action](https://github.com/Mic92/niks3-action):

```yaml
permissions:
  id-token: write
steps:
  - uses: actions/checkout@v4
  - uses: cachix/install-nix-action@v27
  - uses: Mic92/niks3-action@v1
    with:
      server-url: https://niks3.<account>.workers.dev
  - run: nix build .#foo
```

## Garbage collection

Niks3's GC is explicitly triggered, because its retention period is a policy
decision. After choosing one, invoke it from an authenticated operator session,
for example:

```sh
niks3 gc --server-url https://niks3.<account>.workers.dev --older-than 720h
```

Do not schedule GC until that retention policy and the expected cache growth
have been reviewed.
