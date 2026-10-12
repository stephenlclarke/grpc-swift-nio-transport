# Synchronize the container dependency fork

## Motivation

The container-only dependency fork is missing commits from grpc/grpc-swift-nio-transport. Include upstream main ff4420d7c33cc998a590b0761630d67f76bc291e while retaining required fork changes. Unrelated repositories are outside this task.

## Acceptance

Preserve the previous refs, merge upstream without rewriting history, and pass the affected dependency tests before publishing to the Stephen-owned fork.
