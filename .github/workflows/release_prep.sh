#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Argument provided by reusable workflow caller, see
# https://github.com/bazel-contrib/.github/blob/d197a6427c5435ac22e56e33340dff912bc9334e/.github/workflows/release_ruleset.yaml#L72
TAG=$1
# The prefix is chosen to match what GitHub generates for source archives
# This guarantees that users can easily switch from a released artifact to a source archive
# with minimal differences in their code (e.g. strip_prefix remains the same)
PREFIX="rules_uniffi-${TAG:1}"
ARCHIVE="rules_uniffi-$TAG.tar.gz"

# NB: configuration for 'git archive' is in /.gitattributes
git archive --format=tar --prefix=${PREFIX}/ ${TAG} | gzip > $ARCHIVE
SHA=$(shasum -a 256 $ARCHIVE | awk '{print $1}')

# Add generated API docs to the release, see https://github.com/bazelbuild/bazel-central-registry/issues/5593
docs="$(mktemp -d)"; targets="$(mktemp)"

# examples dir breaks docs extraction TODO: fix this
# bazel --output_base="$docs" query --output=label --output_file="$targets" 'kind("starlark_doc_extract rule", //...)'
bazel --output_base="$docs" build --target_pattern_file="$targets"
tar --create --auto-compress \
    --directory "$(bazel --output_base="$docs" info bazel-bin)" \
    --file "$GITHUB_WORKSPACE/${ARCHIVE%.tar.gz}.docs.tar.gz" .

cat << EOF
## Using Bzlmod

Add to your \`MODULE.bazel\` file:

\`\`\`starlark
bazel_dep(name = "rules_uniffi", version = "${TAG:1}")
archive_override(
  module_name = "rules_uniffi",
  urls = ["https://github.com/christian-belloni/rules_uniffi/releases/download/${TAG}/${ARCHIVE}"],
  integrity = "${SHA}"
)
\`\`\`

## Using legacy WORKSPACE

Paste this snippet into your \`WORKSPACE.bazel\` file:

\`\`\`starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(
    name = "rules_uniffi",
    sha256 = "${SHA}",
    strip_prefix = "${PREFIX}",
    url = "https://github.com/christian-belloni/rules_uniffi/releases/download/${TAG}/${ARCHIVE}",
)
EOF

echo "\`\`\`"
