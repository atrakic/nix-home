# ── nix-home Makefile ────────────────────────────────────────────────────────
# Usage:
#   make          → apply (macOS) or test (Linux, CI)
#   make update   → update all flake inputs then apply  [macOS only]
#   make check    → lint / evaluate the flake without building
#   make fmt      → format all .nix files
#   make test     → run lint/check suite in a Nix Docker container (Linux)
#   make gc       → garbage collect Nix store
#   make clean    → remove result symlink

FLAKE      := $(CURDIR)
UNAME      := $(shell uname -s)
HOSTNAME   := $(shell hostname -s 2>/dev/null || echo "$${HOSTNAME:-unknown}")
NIX        := nix --extra-experimental-features "nix-command flakes"
DOCKER     := DOCKER_HOST=unix:///var/run/docker.sock docker compose

ifeq ($(UNAME),Darwin)
  REBUILD  := darwin-rebuild switch --flake "$(FLAKE)#$(HOSTNAME)"
else
  REBUILD  := sudo nixos-rebuild switch --flake "$(FLAKE)#$(HOSTNAME)"
endif

# On Linux (container / CI) default to the lint+check suite; on macOS apply.
ifeq ($(UNAME),Darwin)
  .DEFAULT_GOAL := apply
else
  .DEFAULT_GOAL := ci
endif

# ── Primary targets ──────────────────────────────────────────────────────────

.PHONY: apply
apply:                        ## ★ Apply config (darwin-rebuild on macOS, nixos-rebuild on Linux)
	$(REBUILD)

.PHONY: update
update:                       ## Update flake inputs then apply
	$(NIX) flake update
	$(REBUILD)

.PHONY: check
check:                        ## Evaluate flake without building (fast lint)
	$(NIX) flake check --no-build

.PHONY: fmt
fmt:                          ## Format all .nix files
	$(NIX) fmt .

.PHONY: gc
gc:                           ## Garbage collect old Nix generations
	sudo nix-collect-garbage --delete-older-than 14d
	nix-collect-garbage --delete-older-than 14d

.PHONY: pre-commit-install
pre-commit-install:           ## Install git pre-commit hooks (auto-runs in nix develop)
	$(NIX) develop --command pre-commit install

.PHONY: pre-commit-run
pre-commit-run:               ## Run all pre-commit hooks against all files
	$(NIX) develop --command pre-commit run --all-files

.PHONY: lint
lint:                         ## Run deadnix + statix linters locally
	$(NIX) run nixpkgs#deadnix -- --fail .
	$(NIX) run nixpkgs#statix -- check .

.PHONY: ci
ci: fmt lint check pre-commit-run ## Run all CI checks locally (mirrors pipeline)

.PHONY: docker-test
docker-test:                  ## Run lint/check suite inside a Nix Docker container
	$(DOCKER) run --rm test

.PHONY: test
test: docker-test             ## Alias for docker-test

.PHONY: docker-shell
docker-shell:                 ## Open an interactive shell in the Nix container (for debugging)
	$(DOCKER) run --rm -it --entrypoint sh test

.PHONY: docker-clean
docker-clean:                 ## Remove Docker test image and nix-store volume
	$(DOCKER) down --rmi local --volumes

.PHONY: clean
clean:                        ## Remove result symlink
	rm -f result

# ── Bootstrap (first run only) ────────────────────────────────────────────────

.PHONY: bootstrap
bootstrap:                    ## Install nix-darwin for the first time
	@echo "→ Installing nix-darwin…"
	$(NIX) run nix-darwin -- switch --flake "$(FLAKE)"

# ── Info ─────────────────────────────────────────────────────────────────────

.PHONY: show
show:                         ## Show flake outputs
	$(NIX) flake show .

.PHONY: diff
diff:                         ## Show what would change (dry-run)
	$(REBUILD) --dry-run 2>&1 | head -60

.PHONY: help
help:                         ## Print this help message
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'
