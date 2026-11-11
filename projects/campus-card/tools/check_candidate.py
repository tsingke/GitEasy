#!/usr/bin/env python3
"""Build and test exactly the tracked index contents, including staged deletions."""
from pathlib import Path
import os,subprocess,tempfile
root=Path(subprocess.check_output(['git','rev-parse','--show-toplevel'],text=True).strip())
if subprocess.check_output(['git','ls-files','-u'],cwd=root):raise SystemExit('Unmerged index: resolve before checking a candidate')
with tempfile.TemporaryDirectory(prefix='campus-candidate-') as folder:
    base=Path(folder);source=base/'source';source.mkdir()
    subprocess.run(['git','checkout-index','--all','--prefix='+str(source)+os.sep],cwd=root,check=True)
    # Standalone project labs use the repository root; GitEasy stores the same project below projects/.
    project=source if (source/'CMakeLists.txt').exists() else source/'projects/campus-card'
    subprocess.run(['cmake','-S',str(project),'-B',str(base/'build'),'-DCMAKE_BUILD_TYPE=Release'],check=True)
    subprocess.run(['cmake','--build',str(base/'build'),'--config','Release','--parallel','2'],check=True)
    subprocess.run(['ctest','--test-dir',str(base/'build'),'-C','Release','--output-on-failure'],check=True)
print('Candidate index build and tests passed')
