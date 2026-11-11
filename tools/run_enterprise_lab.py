#!/usr/bin/env python3
"""Run the full campus-card version-management route in a disposable sandbox."""
from pathlib import Path
import subprocess,sys
root=Path(__file__).resolve().parents[1]
subprocess.run([sys.executable,str(root/'tools/run_lab.py'),'--chapter','17',*sys.argv[1:]],check=True)
