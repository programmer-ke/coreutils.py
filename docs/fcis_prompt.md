# The Functional Core Imperative Shell (FCIS) Pattern

The functional core will express the domain or business logic
in a pure, side-effect free way that is easily testable with
a fast lightweight test suite with deterministic
inputs and outputs.

This will be surrounded by the imperative shell that takes
care of real world I/O like filesystem, database and
network access.

