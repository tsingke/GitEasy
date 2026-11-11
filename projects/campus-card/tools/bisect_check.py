#!/usr/bin/env python3
"""Return 0 for passing, 1 for failing tests, and 125 for an unbuildable revision."""
import subprocess,sys
for command in [['cmake','-S','.','-B','build-bisect','-DCMAKE_BUILD_TYPE=Release'],['cmake','--build','build-bisect','--config','Release','--clean-first','--parallel','2']]:
    if subprocess.run(command).returncode:sys.exit(125)
sys.exit(0 if subprocess.run(['ctest','--test-dir','build-bisect','-C','Release','--output-on-failure']).returncode==0 else 1)
