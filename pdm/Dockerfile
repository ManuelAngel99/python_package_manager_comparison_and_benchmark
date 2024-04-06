FROM python:3.12.2

# install PDM
RUN pip install -U pdm
# disable update check
ENV PDM_CHECK_UPDATE=false
# copy files
COPY pyproject.toml pdm.lock README.md /project/
COPY src/ /project/src

# install dependencies and project into the local packages directory
WORKDIR /project
RUN pdm install --check --prod --no-editable

# retrieve packages from build stage
ENV PATH="/project/.venv/bin:$PATH"

COPY src .
ENTRYPOINT  ["python"]