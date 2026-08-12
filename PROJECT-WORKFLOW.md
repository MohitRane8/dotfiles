# AI Project Workflow

Use this workflow when starting a project or making a non-trivial change to an
existing one. Its goal is to expose assumptions before implementation, then work
autonomously from approved intent.

## Starting Context

Follow `AGENTS.md` for required project context and operating rules. The conversation
prompt supplies the current stage and active change spec, if any. Resume at that
stage rather than restarting the workflow.

## Default Flow

```text
grill-with-docs → [to-spec] → preview doc deltas → [to-tickets] → implement → code-review → reconcile MAIN-SPEC.md
```

- `to-spec` and `to-tickets` are optional for small, one-session changes.
- Preview documentation deltas in chat before implementation. Do not edit files at
  this stage; obtain approval for the intended `MAIN-SPEC.md` or `README.md` changes.
- Implement the approved scope and verify observable behavior.
- Review the result against the approved intent and repository standards.
- Reconcile documentation after review, in the implementation conversation, using
  the completion rules in `AGENTS.md`. No documentation change may be necessary.
