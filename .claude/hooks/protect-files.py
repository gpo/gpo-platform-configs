#!/usr/bin/env python3
"""PreToolUse guard for Write/Edit calls.

Enforces two repo rules mechanically (CLAUDE.md states them, this blocks them):
1. secrets*.env files may only contain SOPS-encrypted values (ENC[...]) and
   sops metadata — never plaintext secrets.
2. Terraform stays in tf/, Kubernetes manifests stay in kubernetes/.

Exit 0 allows the call; exit 2 blocks it and feeds stderr back to the model.
"""

import json
import re
import sys
from pathlib import PurePosixPath

SOPS_META_PREFIXES = ("sops_", "#")


def fail(msg: str) -> None:
    print(msg, file=sys.stderr)
    sys.exit(2)


def new_content(tool_name: str, tool_input: dict) -> str:
    if tool_name == "Write":
        return tool_input.get("content", "")
    if tool_name == "Edit":
        return tool_input.get("new_string", "")
    if tool_name == "MultiEdit":
        return "\n".join(e.get("new_string", "") for e in tool_input.get("edits", []))
    return ""


def check_secrets_env(path: PurePosixPath, content: str) -> None:
    if not (path.name.startswith("secrets") and path.suffix == ".env"):
        return
    for line in content.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith(SOPS_META_PREFIXES):
            continue
        if "=" not in stripped:
            continue
        key, value = stripped.split("=", 1)
        if key.strip().startswith("sops"):
            continue
        if not value.strip().startswith("ENC["):
            fail(
                f"Blocked: {path} may only contain SOPS-encrypted values. "
                f"Line for key '{key.strip()}' is not ENC[...]. Encrypt with "
                "sops instead of writing plaintext secrets."
            )


def check_layer_separation(path: PurePosixPath, content: str) -> None:
    parts = path.parts
    if "kubernetes" in parts and path.suffix == ".tf":
        fail(
            "Blocked: Terraform files do not belong under kubernetes/. "
            "Terraform lives in tf/ (see CLAUDE.md)."
        )
    if "tf" in parts and path.suffix in (".yaml", ".yml"):
        if re.search(r"^\s*apiVersion\s*:", content, re.M) and re.search(
            r"^\s*kind\s*:", content, re.M
        ):
            fail(
                "Blocked: this looks like a Kubernetes manifest, which does "
                "not belong under tf/. Kubernetes manifests live in "
                "kubernetes/ (see CLAUDE.md)."
            )


def main() -> None:
    data = json.load(sys.stdin)
    tool_input = data.get("tool_input", {})
    file_path = tool_input.get("file_path")
    if not file_path:
        return
    path = PurePosixPath(file_path)
    content = new_content(data.get("tool_name", ""), tool_input)
    check_secrets_env(path, content)
    check_layer_separation(path, content)


if __name__ == "__main__":
    main()
