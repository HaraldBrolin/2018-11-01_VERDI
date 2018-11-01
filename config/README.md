This is where i keep my configfiles, track my conda environmnet and R-packages.

To create the spec-file.txt, run follwoing command:
conda list --explicit > spec-file.txt

To recreate a new a new copy of the environment using the same packages, run followin command.
conda create --name myenv --file spec-file.txt
