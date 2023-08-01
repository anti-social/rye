.PHONY: all
all: test

.PHONY: build
build:
	@cargo build --all

.PHONY: test
test:
	@cargo test --all

.PHONY: check
check:
	@cargo check --all

.PHONY: format
format:
	@cargo fmt --all

.PHONY: format-check
format-check:
	@cargo fmt --all -- --check

.PHONY: serve-docs
serve-docs: .venv
	@rye run serve-docs

.PHONY: lint
lint:
	@cargo clippy --all -- -D clippy::dbg-macro -D warnings

.venv:
	@rye sync


CONTAINER_ENGINE ?= podman
CLI_TEST_EXE = target/x86_64-unknown-linux-gnu/debug/rye

.PHONY: build-test-exe
build-test-exe:
	@env CROSS_CONTAINER_ENGINE=$(CONTAINER_ENGINE) cross build

.PHONY: build-test-image
build-test-image: build-test-exe
	@$(CONTAINER_ENGINE) build \
	  -t rye-test \
	  -f Containerfile \
	  --build-arg RYE_EXE_PATH=$(CLI_TEST_EXE) \
	  --build-arg RYE_EXE_HASH=$$(sha256sum $(CLI_TEST_EXE) | cut -d ' ' -f 1) \
	  .

.PHONY: test-cli
test-cli:
	@$(CONTAINER_ENGINE) run --rm -it \
	  -v $$(pwd)/integ-tests:/work \
	  -v $$(pwd)/$(CLI_TEST_EXE):/opt/rye/shims/rye \
	  -w /work \
	  rye-test \
	  bats .
