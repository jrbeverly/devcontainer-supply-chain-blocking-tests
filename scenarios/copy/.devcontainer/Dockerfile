FROM node:20-slim

# Copy and activate the portable npm policy before any dependency activity.
COPY policy/activate.sh /tmp/policy/activate.sh
RUN sh /tmp/policy/activate.sh

# The approved local fixture installs without consulting the configured
# registry, so it must succeed after activation.
WORKDIR /tmp/approved-check
COPY fixtures/approved-package ./approved-package
RUN npm install ./approved-package --no-audit --no-fund

# An ordinary public-registry install must fail after activation. The build
# fails if this expectation reverses.
RUN mkdir -p /tmp/public-check \
    && cd /tmp/public-check \
    && if npm install is-odd --no-audit --no-fund >/dev/null 2>&1; then \
        echo "ERROR: public registry install succeeded despite policy" >&2; \
        exit 1; \
    else \
        echo "OK: public registry install failed as expected"; \
    fi
