import subprocess
import os

@custom
def transform_custom(*args, **kwargs):
    project_path = os.path.abspath(os.path.join(os.getcwd(), 'dbt_duckdb_dwh'))

    result = subprocess.run(
        ['python', 'refresh_sources.py'],
        cwd=project_path,
        capture_output=True,
        text=True
    )

    return {
        'stdout': result.stdout,
        'stderr': result.stderr,
        'returncode': result.returncode
    }

@test
def test_output(output, *args) -> None:
    assert output['returncode'] == 0, f"refresh_sources.py failed: {output['stderr']}"
