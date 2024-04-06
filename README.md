# Comparaison between poetry, pde and rye, using both pip/piptools and uv backends

## Pre-requisites

- [just](benchmark_venv_creation_time_cached_dependencies) command runner
- [poetry](https://python-poetry.org/docs/#installation)
- [rye](https://rye-up.com/), during the installation process, select the `uv` backend
- [pdm](https://pdm.fming.dev/)
- [docker](https://docs.docker.com/get-docker/)
## Docker image build time benchmark

Using rye with the `uv` backend is the fastest option, with a build time of ~10 seconds. Poetry is the seond fastest option, with a build time of ~20 seconds. However, when using the `pip` backend, rye is significantly slower, with a build time of ~35 seconds. pdm is the slowest option, being almost 5 times slower than rye+uv with a build time of ~48 seconds.

Replicte the benchmark with:

```bash
just benchmark_image_build_time
```

Raw Results:

```text
********************
Running non-cached image build time benchmarks
********************

Pulling python:3.12.2 image
docker pull python:3.12.2 --quiet
docker.io/library/python:3.12.2

Benchmarking poetry image build time
cd poetry && time -f "Results:\nTime elapsed: %E\n" docker build . --no-cache --quiet -t "poetry:benchmark"
sha256:754ad7b9a6da2bb1a718b32870be49d6c7f08ff7d8ff52f45719aa62576ff49e
Results:
Time elapsed: 0:20.92

Benchmarking rye image build time using the pip backend
cd rye && time -f "Results:\nTime elapsed: %E\n" docker build -f Dockerfile.pip . --no-cache --quiet -t "rye:benchmark.pip"
sha256:6487d361d41e0d143bc4a76726f49b173e1f990726ef34ba126414e1145e1d11
Results:
Time elapsed: 0:35.88

Benchmarking rye image build time using the uv backend
cd rye && time -f "Results:\nTime elapsed: %E\n" docker build -f Dockerfile.uv . --no-cache --quiet -t "rye:benchmark.uv"
sha256:d96e6bcff58689d4c70068cb456c1e1ede1bdc4c8e1dc1017eec802f4f7d07eb
Results:
Time elapsed: 0:10.17

Benchmarking pdm image build time
cd pdm && time -f "Results:\nTime elapsed: %E\n" docker build . --no-cache --quiet -t "pdm:benchmark"
sha256:a18f338895bc8b674cf5276a5145ecbb405452dbcdf0c600fd9196a46d157cc0
Results:
Time elapsed: 0:48.05

```

## Lock file generation benchmark

Rye+uv is the fastest option for lock file generation, with a time of ~0.09 seconds. Poetry is the slowest option, with a time of ~5.36 seconds. It is surprising that pdm is this slow (23.87 seconds), looking at the results of the virtual environament creation benchmark, it seems like it takes roughly the same time to generate the lock file and create the virtual environment.

Replicte the benchmark with:

```bash
just benchmark_lock_file_generation_time
```

Results:

```text
********************
Running lock file generation time benchmarks
********************

Benchmarking poetry lock file generation time
cd poetry && rm -rf .venv poetry.lock
cd poetry && time -f "Results:\nTime elapsed: %E\n" poetry lock -q
Results:
Time elapsed: 0:05.26

Benchmarking rye lock file generation time using the uv backend
cd rye && rm -rf .venv requirements.lock requirements-dev.lock
cd rye && time -f "Results:\nTime elapsed: %E\n" rye lock -q
Results:
Time elapsed: 0:00.09

Benchmarking pdm lock file generation time
cd pdm && rm -rf .venv pdm.lock
cd pdm && time -f "Results:\nTime elapsed: %E\n" bash -c "pdm lock -q > /dev/null 2>&1"
Results:
Time elapsed: 0:23.87
```

## Virtual environment creation benchmark

Once again, rye+uv is way faster than poetry: 0.12 seconds vs 5.77 seconds. I have not tested the `pip` backend for `rye` outside of the docker image, but I expect it to be slower than the poetry installation. PDM is, as expected, the slowest option, with a time of 20.66 seconds.

Replicte the benchmark with:

```bash
just benchmark_venv_creation_time_cached_dependencies
```

Results with cached packages (no download from pypi required):

Results:

```text
********************
Running virtual environment creation time benchmarks with dependencies cached
********************

Warmup: Installing dependencies using poetry and rye so packages are cached
cd poetry && poetry install -q
cd rye && rye sync -q
cd pdm && pdm install -q > /dev/null 2>&1
Benchmarking poetry virtual environment creation time
cd poetry && rm -rf .venv
cd poetry && time -f "Results:\nTime elapsed: %E\n" poetry install -q
Results:
Time elapsed: 0:05.51

Benchmarking ryelock virtual environment generation time using the uv backend
cd rye && rm -rf .venv
cd rye && time -f "Results:\nTime elapsed: %E\n" rye sync -q
Results:
Time elapsed: 0:00.13

Benchmarking pdm virtual environment creation time
cd pdm && rm -rf .venv
cd pdm && time -f "Results:\nTime elapsed: %E\n" bash -c "pdm install -q > /dev/null 2>&1"
Results:
Time elapsed: 0:20.66
```
