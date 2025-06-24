import subprocess
import os
import duckdb
from typing import Dict, Any

@custom
def run_dbt(*args, **kwargs) -> Dict[str, Any]:
    # First verify DuckDB connection
    db_path = os.path.abspath(os.path.join(os.getcwd(), 'dbt_duckdb_dwh', 'dev.duckdb'))
    try:
        conn = duckdb.connect(database=db_path)
        tables = conn.execute("SHOW TABLES").fetchall()
        print(f"Connected to DuckDB at {db_path}")
        print(f"Existing tables: {tables}")
        conn.close()
    except Exception as e:
        return {
            'error': f"Failed to connect to DuckDB: {str(e)}",
            'returncode': 1
        }
    
    # Then run dbt
    project_dir = os.path.abspath(os.path.join(os.getcwd(), 'dbt_duckdb_dwh'))
    profiles_dir = os.path.expanduser("~/.dbt")
    
    result = subprocess.run(
        ['dbt', 'run', 
         '--project-dir', project_dir, 
         '--profiles-dir', profiles_dir,
         '--target', 'dev'],
        capture_output=True,
        text=True
    )
    
    return {
        'stdout': result.stdout,
        'stderr': result.stderr,
        'returncode': result.returncode
    }