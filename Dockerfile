FROM hasura/graphql-engine:v1.0.0 as base
FROM python:3.7-slim-buster

RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends build-essential aria2 libpq-dev postgresql-client

# Copy hausra binary from base container
COPY --from=base /bin/graphql-engine /bin/graphql-engine

# Set up shop in il-campaign-finance-api directory
WORKDIR /il-campaign-finance-api/

# Install ETL / processing
COPY ilcampaigncash/Makefile Makefile
COPY ilcampaigncash/Pipfile Pipfile
COPY ilcampaigncash/Pipfile.lock Pipfile.lock
ADD ilcampaigncash/data/ data/
ADD ilcampaigncash/sql/ sql/
ADD ilcampaigncash/processors/ processors/
ADD scripts/ scripts/

# Set up virtualenv in project directory
ENV PIPENV_VENV_IN_PROJECT=1
RUN pip install pipenv
RUN pipenv install --deploy --ignore-pipfile

# The makefile requires a dotenv file; it's empty because the variables come from
# Heroku instead
RUN touch .env

# Run Hasura
CMD graphql-engine \
    --database-url $DATABASE_URL \
    serve \
    --server-port $PORT