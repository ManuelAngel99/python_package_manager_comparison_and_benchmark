install_rye:
    @echo "Installing Rye"
    curl -sSf https://rye-up.com/get | bash

install_uv:
    @echo "Installing UV"
    pip install uv

install_poetry:
    @echo "Installing Poetry"
    curl -sSL https://install.python-poetry.org | python3 -

benchmark_image_build_time:
    @echo "********************"
    @echo "Running non-cached image build time benchmarks"
    @echo "********************"
    @echo ""

    @echo "Pulling python:3.12.2 image"
    docker pull python:3.12.2 --quiet
    @echo ""

    @echo "Benchmarking poetry image build time"
    cd poetry && time -f "Results:\nTime elapsed: %E\n" docker build . --no-cache --quiet -t "poetry:benchmark"
    @echo "Benchmarking rye image build time using the pip backend"
    cd rye && time -f "Results:\nTime elapsed: %E\n" docker build -f Dockerfile.pip . --no-cache --quiet -t "rye:benchmark.pip"
    @echo "Benchmarking rye image build time using the uv backend"
    cd rye && time -f "Results:\nTime elapsed: %E\n" docker build -f Dockerfile.uv . --no-cache --quiet -t "rye:benchmark.uv"
    @echo "Benchmarking pdm image build time"
    cd pdm && time -f "Results:\nTime elapsed: %E\n" docker build . --no-cache --quiet -t "pdm:benchmark"


benchmark_lock_file_generation_time:
    @echo "********************"
    @echo "Running lock file generation time benchmarks"
    @echo "********************"
    @echo ""

    @echo "Benchmarking poetry lock file generation time"
    cd poetry && rm -rf .venv poetry.lock
    cd poetry && time -f "Results:\nTime elapsed: %E\n" poetry lock -q
    

    @echo "Benchmarking rye lock file generation time using the uv backend"
    cd rye && rm -rf .venv requirements.lock requirements-dev.lock
    cd rye && time -f "Results:\nTime elapsed: %E\n" rye lock -q

    @echo "Benchmarking pdm lock file generation time"
    cd pdm && rm -rf .venv pdm.lock
    cd pdm && time -f "Results:\nTime elapsed: %E\n" bash -c "pdm lock -q > /dev/null 2>&1"

benchmark_venv_creation_time_cached_dependencies:
    @echo "********************"
    @echo "Running virtual environment creation time benchmarks with dependencies cached"
    @echo "********************"
    @echo ""

    @echo "Warmup: Installing dependencies using poetry and rye so packages are cached"
    cd poetry && poetry install -q
    cd rye && rye sync -q
    cd pdm && pdm install -q > /dev/null 2>&1

    @echo "Benchmarking poetry virtual environment creation time"
    cd poetry && rm -rf .venv
    cd poetry && time -f "Results:\nTime elapsed: %E\n" poetry install -q
    

    @echo "Benchmarking ryelock virtual environment generation time using the uv backend"
    cd rye && rm -rf .venv
    cd rye && time -f "Results:\nTime elapsed: %E\n" rye sync -q

    @echo "Benchmarking pdm virtual environment creation time"
    cd pdm && rm -rf .venv
    cd pdm && time -f "Results:\nTime elapsed: %E\n" bash -c "pdm install -q > /dev/null 2>&1"