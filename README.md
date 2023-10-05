# Intel oneAPI MPI Library

This is a flake to use Intel [oneAPI MPI Library](https://www.intel.com/content/www/us/en/developer/tools/oneapi/mpi-library.html).

## Requirements

A working installation of Nix on Linux x86_64

## Usage

1. Clone this repository and run:
   ```bash
   cd intel-mpi-nix
   nix develop
   ```
2. Compile the provided Hello World example with:
   ```bash
   mpicc -o hello hello.c
   ```
3. Run the example with:
   ```bash
   mpirun hello
   ```

Alternatively, you can run the development environment directly from Github with:
```bash
nix develop github:waltermoreira/intel-mpi-nix
```
and use the environment to compile your own sources.

If this flake is composed with other flakes, make sure to include the following code before running any of the `mpi*` commands in your derivation (the development environment does it automatically when using `nix develop`):
```
source ${flake-ref}/env/vars.sh
```
where `flake-ref` is the variable bound to this flake in the composition.

## License 

MIT
