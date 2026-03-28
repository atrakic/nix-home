# -- nix-home Makefile --------------------------------------------------------
# Usage:
#   make          -> apply (macOS) or test (Linux, CI)
#   make update   -> update all flake inputs then apply  [macOS only]
#   make check    -> lint / evaluate the flake without building
#   make fmt      -> format all .nix files
#   make test     -> run lint/check suite in a Nix Docker container (Linux)
#   make gc       -> garbage collect Nix store
#   make clean    -> remove result symlink

FLAKE      := $(CURDIR)
UNAME      := $(shell uname -s)
HOSTNAME   := $(shell h=$$(hostname -s 2>/dev/null || hostname 2>/dev/null || echo "$${HOSTNAME:-unknown}"); printf '%s' "$${h%%.*}")
NIX_BIN    := $(shell command -v nix 2>/dev/null || echo /nix/var/nix/profiles/default/bin/nix)
NIX        := $(NIX_BIN) --extra-experimental-features "nix-command flakes"
ROOT_PATH  := /nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
ROOT_NIX   := sudo env PATH="$(ROOT_PATH)" nix --extra-experimental-features "nix-command flakes"
DOCKER     := DOCKER_HOST=unix:///var/run/docker.sock docker compose
TARGET_HOST ?=

# Resolve flake host key:
# 1) explicit TARGET_HOST (if provided)
# 2) current hostname if present in corresponding host map
# 3) first key in corresponding host map
ifeq ($(UNAME),Darwin)
	DEFAULT_FLAKE_HOST := $(shell \
		if grep -Eq '"$(HOSTNAME)"[[:space:]]*=' "$(FLAKE)/flake.nix"; then \
			echo "$(HOSTNAME)"; \
		else \
			awk '/darwinHosts[[:space:]]*=[[:space:]]*\{/{inset=1;next} inset && /\};/{inset=0} inset && match($$0,/"([^"]+)"[[:space:]]*=/,m){print m[1]; exit}' "$(FLAKE)/flake.nix"; \
		fi)
else
	DEFAULT_FLAKE_HOST := $(shell \
		if grep -Eq '"$(HOSTNAME)"[[:space:]]*=' "$(FLAKE)/flake.nix"; then \
			echo "$(HOSTNAME)"; \
		else \
			awk '/linuxHosts[[:space:]]*=[[:space:]]*\{/{inset=1;next} inset && /\};/{inset=0} inset && match($$0,/"([^"]+)"[[:space:]]*=/,m){print m[1]; exit}' "$(FLAKE)/flake.nix"; \
		fi)
endif

FLAKE_HOST := $(if $(TARGET_HOST),$(TARGET_HOST),$(DEFAULT_FLAKE_HOST))

# Make spawns a non-interactive sh that doesn't source shell profiles.
# Prepend the standard Nix / nix-darwin binary paths so tools are found.
export PATH := /opt/homebrew/bin:/usr/local/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$(PATH)


# On Linux (container / CI) default to the lint+check suite; on macOS apply.
ifeq ($(UNAME),Darwin)
  .DEFAULT_GOAL := apply
else
  .DEFAULT_GOAL := ci
endif

# -- Primary targets ----------------------------------------------------------

.PHONY: apply
apply: ensure-host ensure-brew ensure-darwin-etc ## * Apply config (darwin-rebuild on macOS, nixos-rebuild on Linux)
ifeq ($(UNAME),Darwin)
	@if command -v darwin-rebuild >/dev/null 2>&1; then \
		darwin-rebuild switch --flake "$(FLAKE)#$(FLAKE_HOST)"; \
	else \
		$(ROOT_NIX) run nix-darwin -- switch --flake "$(FLAKE)#$(FLAKE_HOST)"; \
	fi
else
	sudo nixos-rebuild switch --flake "$(FLAKE)#$(FLAKE_HOST)"
endif

.PHONY: update
update: ensure-host ensure-brew ensure-darwin-etc ## Update flake inputs then apply
	$(NIX) flake update
ifeq ($(UNAME),Darwin)
	@if command -v darwin-rebuild >/dev/null 2>&1; then \
		darwin-rebuild switch --flake "$(FLAKE)#$(FLAKE_HOST)"; \
	else \
		$(ROOT_NIX) run nix-darwin -- switch --flake "$(FLAKE)#$(FLAKE_HOST)"; \
	fi
else
	sudo nixos-rebuild switch --flake "$(FLAKE)#$(FLAKE_HOST)"
endif

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

# -- Bootstrap (first run only) ------------------------------------------------

.PHONY: bootstrap
bootstrap: ensure-host ensure-brew ensure-darwin-etc ## Install nix-darwin for the first time
	@echo "-> Installing nix-darwin..."
	$(ROOT_NIX) run nix-darwin -- switch --flake "$(FLAKE)#$(FLAKE_HOST)"

# -- Info ---------------------------------------------------------------------

.PHONY: show
show:                         ## Show flake outputs
	$(NIX) flake show .

.PHONY: diff
diff: ensure-host ensure-brew ensure-darwin-etc ## Show what would change (dry-run)
ifeq ($(UNAME),Darwin)
	@if command -v darwin-rebuild >/dev/null 2>&1; then \
		darwin-rebuild switch --flake "$(FLAKE)#$(FLAKE_HOST)" --dry-run 2>&1 | head -60; \
	else \
		$(ROOT_NIX) run nix-darwin -- switch --flake "$(FLAKE)#$(FLAKE_HOST)" --dry-run 2>&1 | head -60; \
	fi
else
	sudo nixos-rebuild switch --flake "$(FLAKE)#$(FLAKE_HOST)" --dry-run 2>&1 | head -60
endif

.PHONY: ensure-host
ensure-host:
	@if [ -z "$(FLAKE_HOST)" ]; then \
		echo "ERROR: Could not resolve flake host key from flake.nix."; \
		echo "Set one explicitly: make $$@ TARGET_HOST=<host-key>"; \
		exit 1; \
	fi
	@echo "Using flake host: $(FLAKE_HOST)"

.PHONY: ensure-brew
ensure-brew:
ifeq ($(UNAME),Darwin)
	@if command -v brew >/dev/null 2>&1; then \
		echo "Homebrew found: $$(command -v brew)"; \
	else \
		echo "Homebrew not found. Installing Homebrew..."; \
		NONINTERACTIVE=1 /bin/bash -c "$$(/usr/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	fi
else
	@true
endif

.PHONY: ensure-darwin-etc
ensure-darwin-etc:
ifeq ($(UNAME),Darwin)
	@if [ ! -e /etc/synthetic.conf ]; then \
		echo "Creating /etc/synthetic.conf"; \
		sudo touch /etc/synthetic.conf; \
		sudo chmod 644 /etc/synthetic.conf; \
	fi
	@if ! awk '$$1 == "run" && $$2 == "private/var/run" { found = 1 } END { exit found ? 0 : 1 }' /etc/synthetic.conf; then \
		echo "Adding /run synthetic mapping to /etc/synthetic.conf"; \
		printf 'run\tprivate/var/run\n' | sudo tee -a /etc/synthetic.conf >/dev/null; \
	fi
	@if [ ! -e /run ] || { [ "$$(readlink /run 2>/dev/null)" != "/private/var/run" ] && [ "$$(readlink /run 2>/dev/null)" != "private/var/run" ]; }; then \
		echo "Applying synthetic filesystem entries"; \
		if ! sudo /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t; then \
			echo "ERROR: macOS did not materialize /run from /etc/synthetic.conf."; \
			echo "A reboot is required after adding the synthetic entry."; \
			echo "Reboot, then rerun: make apply NIXPKGS_ALLOW_UNFREE=1"; \
			exit 1; \
		fi; \
		if [ ! -e /run ] || { [ "$$(readlink /run 2>/dev/null)" != "/private/var/run" ] && [ "$$(readlink /run 2>/dev/null)" != "private/var/run" ]; }; then \
			echo "ERROR: /run is still not available after apfs.util -t."; \
			echo "Reboot, then rerun: make apply NIXPKGS_ALLOW_UNFREE=1"; \
			exit 1; \
		fi; \
	fi
	@for f in /etc/nix/nix.conf /etc/bashrc /etc/zshrc /etc/zprofile; do \
		if [ -e "$$f" ] && [ ! -L "$$f" ]; then \
			backup="$$f.before-nix-darwin"; \
			if [ ! -e "$$backup" ]; then \
				echo "Archiving $$f -> $$backup"; \
				sudo mv "$$f" "$$backup"; \
			else \
				echo "Backup exists for $$f ($$backup), leaving current file in place"; \
			fi; \
		fi; \
	 done
else
	@true
endif

.PHONY: help
help:                         ## Print this help message
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'
