# Use the official Elixir image with Erlang/OTP 25 and Alpine
FROM elixir:1.17.0-alpine

# Set environment to test
ENV MIX_ENV=test

# Install necessary build tools and dependencies
RUN apk add --no-cache build-base git

# Set the working directory inside the container
WORKDIR /app

# Copy mix files to the container and fetch dependencies
COPY mix.exs mix.lock ./
COPY apps/*/mix.exs ./apps/

# Install Hex and Rebar (Elixir build tools)
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get

# Copy the rest of the project files
COPY . .

# Compile the project
RUN mix deps.compile && mix compile

# Default command to run tests
CMD ["sh"]