# Refresh transport dependencies and local quality admission

## Problem

The quality pull request predates current upstream transport dependencies and the fork's validated connection lifetime fixes. Its local scanner can also attach an old report to a new commit or submit a feature branch as main.

## Expected behavior

Integrate the current fork and upstream requirements into the existing quality pull request. Bind locally generated coverage to its source revision and checksum. Supply local branch context while retaining supported CI pull-request detection.

## Compatibility

No upper-layer pin or published baseline changes. A source update remains distinct from a qualified dependency release. See [implementation](PR-quality-refresh-20261019.md).
