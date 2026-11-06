# Escape during authentication

Prepared on 2026-11-06. The shared Noctalia shell module applies the 5.4.1 backport to its package using `overrideAttrs`, preserving existing package patches. It takes effect on the next NixOS rebuild; no live service has been restarted. PAM configuration, module order, the greeter package, and the lock file are unchanged.

## Upstream findings

- **Noctalia:** no matching issue or PR found for Escape showing “Password cleared” while authentication remains busy. Current `main` still clears only the password/status in this handler.
- **Greeter:** [PR #183](https://github.com/noctalia-dev/noctalia-greeter/pull/183) is open and adds related cancellation handling alongside automatic fingerprint authentication. It supersedes [#158](https://github.com/noctalia-dev/noctalia-greeter/pull/158). It is not a released fix for this report: cancellation waits for the outstanding greetd reply, and ordinary submitted logins still hit the early `m_authenticating` navigation guard.
- [Greeter PR #48](https://github.com/noctalia-dev/noctalia-greeter/pull/48) already fixed re-enabling input after a failed-login cancellation acknowledgement. That fix is present in the installed 1.7.0 and does not implement Escape cancellation.
- [Noctalia issue #3848](https://github.com/noctalia-dev/noctalia/issues/3848) concerns an older fork-related authentication hang, not this Escape state mismatch.

The included patch targets the missing **lock-screen** fix. No duplicate greeter patch is included; its in-flight protocol/cancellation work overlaps #183 and needs coordination rather than assuming that PR already fixes the reported case.

## Patch

`escape-cancels-authentication.patch` is a plain Git-applicable patch for `noctalia-dev/noctalia`, not for this configuration repository. Its base is upstream snapshot `28f1702d2dfb349ced501d0d0ae106efa91bcefd`. The original context of every changed-file hunk also matches upstream `main` as checked on 2026-11-06.

`escape-cancels-authentication-5.4.1.patch` is the package backport used by `flake/modules/gui/noctalia/shell.nix`. It adjusts the Meson test-list context and preserves the release header's `nodiscard` annotations; the fix and regression test are otherwise unchanged.

It:

- Stops the disposable PAM helper when Cancel is pressed, then reaps it on the worker thread.
- Clears the busy state and invalidates the cancelled result, so a late success cannot unlock or overwrite a newer attempt.
- Gives cancellation priority over an action shortcut bound to the same key while authenticating.
- Restores fingerprint handling and guards callbacks against lock-screen destruction.
- Adds helper-protocol regression tests without invoking system PAM, plus user documentation.

The helper still authenticates against the existing `login` service. There is no PAM policy or module-order change.

From a separate Noctalia checkout:

```sh
git apply --check /absolute/path/to/escape-cancels-authentication.patch
git apply /absolute/path/to/escape-cancels-authentication.patch
just test debug pam_authenticator_cancellation --verbose
just build debug
```

## Validation

- Clang-format 23.1.3 checks passed for every changed C++ file.
- Clang-tidy 23 with warnings treated as errors passed for the modified implementation and test files.
- Meson configured successfully; the modified authentication, lock-screen, and test translation units compiled. The debug Nix toolchain emitted its `_FORTIFY_SOURCE requires compiling with optimization` warning.
- The standalone regression executable passed normally and under AddressSanitizer/UndefinedBehaviorSanitizer. It covers normal success/failure, cancellation before starting, blocked password writes, blocked/partial replies, helper exit waits, child reaping, and successful subsequent attempts.
- A negative control with the cancellation callback disabled failed at the two-second completion check, as expected.
- Forward and reverse `git apply --check` passed against the base and modified trees; whitespace validation passed. All changed-file hunk contexts matched current upstream `main`.
- The configured 5.4.1 package built successfully with all 165 Meson tests passing, including `pam_authenticator_cancellation`, and its version install check passed. GCC emitted warnings in unmodified upstream code.
- Pure evaluations of `nyx` and `nyxvm` select the same patched package. The `nyx` Noctalia service unit built successfully, including validation of its generated TOML configuration with the patched binary. Repository Nix formatting and `git diff --check` passed.
- Live authentication tests were not run. Impure host evaluation could not read `/etc/nixos/local.nix`; the pure host checks omit private local overrides. No NixOS rebuild or service restart was attempted.

## Manual coverage still needed

Use a disposable test session or VM, not the only accessible live session:

1. Submit a wrong password, press Escape while authentication is pending, and confirm the controls recover and another password can be submitted.
2. With empty-password submissions allowed, submit without a security key, press Escape, and retry with the correct password or security key.
3. Confirm a cancelled attempt cannot unlock later or replace the status of a newer attempt.
4. Verify normal successful/failed authentication, fingerprint retry, and multiple lock surfaces.
5. Bind a session action to Escape: while authenticating, the first press must cancel rather than run the action.

No real lock screen, YubiKey, fingerprint reader, or greetd session was exercised during preparation. This is a patch for review, not a deployed or hardware-verified fix.
