#!/bin/bash

# I have no idea why the DO TF provider refuses to accept anything but an env var for authenticating
# with spaces, but that seems to be the case.

SPACES_ACCESS_KEY_ID=$(sops decrypt ../../secrets.env --extract '["SPACES_ACCESS_KEY_ID"]')
SPACES_SECRET_ACCESS_KEY=$(sops decrypt ../../secrets.env --extract '["SPACES_SECRET_ACCESS_KEY"]')
SPACES_ACCESS_KEY_ID=${SPACES_ACCESS_KEY_ID} SPACES_SECRET_ACCESS_KEY=${SPACES_SECRET_ACCESS_KEY} tofu $@
