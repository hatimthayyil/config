These policies, and the Version control section above, apply in repos on the `gitbutler/workspace` branch.

### Update from the target branch automatically

- When GitButler status shows new changes on the target branch and the workspace holds only this session's branches, update with `but pull` directly — its output reports the result and `but undo` reverts it.
- If an update you started on your own initiative reports conflicted commits, stop and ask before resolving them (`but undo` reverts the pull if the user prefers).
- When other agents' branches are applied, run `but pull --check` first and ask before updating if it reports conflicts or their branches would move.
- If the user asks you to handle update conflicts, use GitButler's conflict tools. Ask before resolving semantic conflicts, dependency updates, generated files, or conflicts involving another person's work.

### Open draft pull requests by default

- When asked to open a pull request, create it as a draft with GitButler unless the user says it is ready for review.
- Remember that creating a draft pull request still publishes the branch.

### Publish on a shortcut phrase

- When the user says `ship it`, commit this session's changes on its dedicated GitButler branch, creating one if needed.
- Push the branch and open or update its pull request with GitButler.
- Reuse the existing branch or pull request for this session when one already exists.
- Treat this phrase as approval to commit, push, and open or update a pull request without asking again, unless something risky or surprising changed.

### Branch naming

- When creating a GitButler branch for an agent session, use `<type>/<slug>`.

### Commit message convention

- Follow the `Conventional Commits` commit-message convention when writing commit messages.

### Commit checkpoints after each turn

- Commit after a working checkpoint, when the requested change is complete and relevant checks have passed or been reported.
- Treat checkpoint commits as local savepoints, not final review history.
- When the user asks you to tidy the history, use GitButler to squash commits, reword commits, and move changes between commits where appropriate.
- Only tidy unpublished local history unless the user explicitly authorizes changing pushed or shared history.

### Create a recovery point before large history edits

- Before squashing, splitting, moving commits between branches, or reorganizing multiple branches, run `but oplog snapshot -m "<reason>"`.
- Use GitButler history-edit commands such as `but move`, `but squash`, `but reword`, `but absorb`, and `but amend` instead of raw Git rebases.
- If an operation makes the branch or history layout worse, stop and inspect the operation log before attempting another fix.
- Prefer `but undo` or `but oplog restore` over trying to repair a bad state with more history edits.
