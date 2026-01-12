# gpo-platform-configs
Infrastructure as Code for the GPO

Design Doc:
https://docs.google.com/document/d/1-2-MSpd-g_i5UjxHVkZW8wpKUZORjLrzd8A-UhW2XAY/edit

# Requirements

* `gh` with an authenticated session
* [mise en place](https://mise.jdx.dev/)
  * Make sure you configure your shell to [activate mise](https://mise.jdx.dev/cli/activate.html)

# Development

## Install Dependencies

All our local tool deps are managed by `mise`. If you need to adopt a new tool, it needs to be added to [.mise.toml].

Inside the repo run:
1. `mise install`        # to install all our dev tools (eg. jq, opentofu, etc.)
1. `pre-commit install`  # to install our hooks

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
