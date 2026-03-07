# ── nix-home Makefile ────────────────────────────────────────────────────────
# Usage:
#   make          → apply full system + home config  (default)
#   make update   → update all flake inputs then apply
#   make check    → lint / evaluate the flake without building
#   make fmt      → format all .nix files
#   make gc       → garbage collect Nix store
#   make clean    → remove result symlink

FLAKE      := $(CURDIR)
HOSTNAME   := $(shell hostname -s)
NIX        := nix --extra-experimental-features "nix-command flakes"
REBUILD    := darwin-rebuild switch --flake "$(FLAKE)"

.DEFAULT_GOAL := apply

# ── Primary targets ──────────────────────────────────────────────────────────

.PHONY: apply
apply:                        ## ★ Apply config (single command: make)
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

.PHONY: lint
lint:                         ## Run deadnix + statix linters locally
	$(NIX) run nixpkgs#deadnix -- --fail .
	$(NIX) run nixpkgs#statix -- check .

.PHONY: ci
ci: fmt lint check            ## Run all CI checks locally

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
