# Dev Container npm Registry Blocking

> [!WARNING]
> **AI-authored:** This change was autonomously planned and implemented by an AI software factory from a human-authored specification, with possible subsequent human review or modification.

Compares a local dev container feature with a Dockerfile copy step for redirecting npm registry traffic to a blocked endpoint.

```sh
sh checks/run.sh
```

## Notes

- more recent test for this application
- question whether restrictions should live outside the development container itself
- rather than baking controls into the machine/container image; potentially enforce at the host level
- example; control container networking from the host
- defense in depth still possible; host controls + container-level restrictions where useful
- host-based approach may be easier to maintain overall
- tradeoff; requires more orchestration of host configuration
- benefit; container environments stay cleaner/more flexible
- same host-level model could potentially apply to cloud-based environments as well
- especially useful if dev container is intended to retain broad flexibility/control internally
- baking extra guardrails directly into the container feels uncertain/brittle
- permissions can restrict some behaviour; still feels like the wrong layer for primary enforcement
- host-level controls may be the lighter-weight path to the same goal
- reduces need to orchestrate large amounts of environment-specific local development configuration
