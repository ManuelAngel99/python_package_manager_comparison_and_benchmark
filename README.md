# Comparaison between poetry and rye, using both pip/piptools and uv backends

## Pre-requisites

- [just](benchmark_venv_creation_time_cached_dependencies) command runner
- [poetry](https://python-poetry.org/docs/#installation)
- [rye](https://rye-up.com/), during the installation process, select the `uv` backend

## Docker image build time benchmark

Using rye with the `uv` backend is the fastest option, with a build time of ~10 seconds. Poetry is the seond fastest option, with a build time of ~25 seconds. However, when using the `pip` backend, rye is the slowest option, with a build time of ~35 seconds.

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
cd poetry && time -f "Results:\nTime elapsed: %E\n" docker build . --no-cache --quiet
sha256:8b08d8d822e74763628ea982a5f5a163c703b72c609ac3f1aa42fae850f8777c
Results:
Time elapsed: 0:25.10

Benchmarking rye image build time using the pip backend
cd rye && time -f "Results:\nTime elapsed: %E\n" docker build -f Dockerfile.pip . --no-cache --quiet
sha256:5c315e3597399048726a34404f329325c043c00944177a1bc594739458850dbe
Results:
Time elapsed: 0:35.31

Benchmarking rye image build time using the uv backend
cd rye && time -f "Results:\nTime elapsed: %E\n" docker build -f Dockerfile.uv . --no-cache --quiet
sha256:d85d9dbde05a9e4e439bf93a9cb0c95f23b480a1969968dee3cf7124ec893ea0
Results:
Time elapsed: 0:10.05

```

## Lock file generation benchmark

Rye+uv is the fastest option for lock file generation, with a time of ~0.09 seconds. Poetry is the slowest option, with a time of ~5.36 seconds.

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
Time elapsed: 0:05.36

Benchmarking rye lock file generation time using the uv backend
cd rye && rm -rf .venv requirements.lock requirements-dev.lock
cd rye && time -f "Results:\nTime elapsed: %E\n" rye lock -q
Results:
Time elapsed: 0:00.09
```

## Virtual environment creation benchmark

Once again, rye+uv is way faster than poetry: 0.12 seconds vs 5.77 seconds. I have not tested the `pip` backend for `rye` outside of the docker image, but I expect it to be slower than the poetry installation.

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
Benchmarking poetry virtual environment creation time
cd poetry && rm -rf .venv
cd poetry && time -f "Results:\nTime elapsed: %E\n" poetry install -q
Results:
Time elapsed: 0:05.77

Benchmarking ryelock virtual environment generation time using the uv backend
cd rye && rm -rf .venv
cd rye && time -f "Results:\nTime elapsed: %E\n" rye sync -q
Results:
Time elapsed: 0:00.12
```

