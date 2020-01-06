FROM hasura/graphql-engine:v1.0.0 as base
FROM python:3.7-slim-buster

RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends build-essential aria2 pipenv libpq-dev postgresql-client

# Copy hausra binary from base container
COPY --from=base /bin/graphql-engine /bin/graphql-engine

# Install xsv
# RUN cargo install xsv

# Add xsv binary to PATH
# ENV PATH="/root/.cargo/bin/:${PATH}"

# Set up shop in il-campaign-finance-api directory
WORKDIR /il-campaign-finance-api/

# Install ETL / processing
COPY ilcampaigncash/Makefile Makefile
ADD ilcampaigncash/data/ data/
ADD ilcampaigncash/sql/ sql/
ADD ilcampaigncash/processors/ processors/
# ADD ilcampaigncash/scripts/ scripts/

# The makefile requires a dotenv file; it's empty because the variables come from
# Heroku instead
RUN touch .env

# Run Hasura
CMD graphql-engine \
    --database-url $DATABASE_URL \
    serve \
    --server-port $PORT