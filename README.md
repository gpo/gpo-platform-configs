# gpo-platform-configs
Infrastructure as Code for the GPO

Design Doc:
https://docs.google.com/document/d/1-2-MSpd-g_i5UjxHVkZW8wpKUZORjLrzd8A-UhW2XAY/edit

# Requirements

* [mise en place](https://mise.jdx.dev/)
  * Make sure you configure your shell to [activate mise](https://mise.jdx.dev/cli/activate.html)

# Development

## Install Dependencies

All our local tool deps are managed by `mise`. If you need to adopt a new tool, it needs to be added to [.mise.toml].

Inside the repo run:
1. `mise install`        # to install all our dev tools (eg. jq, opentofu, etc.)
1. `pre-commit install`  # to install our hooks

## Claude Code cloud environments

`mise install` above doesn't work in a Claude Code on the web session — confirmed directly, twice (a live session and the actual Setup Script phase): `mise`'s `aqua` backend resolves tools through `api.github.com`, which 403s for any repo the session isn't attached to. Add this to the environment's **Setup Script** field instead, to have tooling ready before the session starts (see `claude/cloud-environment-setup.sh` for why it doesn't just call mise):

```bash
if curl -fsSL "https://raw.githubusercontent.com/gpo/gpo-platform-configs/main/claude/cloud-environment-setup.sh" -o /tmp/cloud-environment-setup.sh; then
  bash /tmp/cloud-environment-setup.sh
else
  echo "gpo-platform-configs: could not fetch cloud-environment-setup.sh during environment setup - tofu/pre-commit/sops/etc. unavailable until this is fixed" >> ~/.cloud-setup-errors.log
fi
```

# Repo Layout

All our TF configs live in the [tf subdir](./tf).

All our K8s configs live in the [kubernetes subdir](./kubernetes).

We have a few helper scripts in the [scripts subdir](./scripts).


# Auto Generated Docs
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
