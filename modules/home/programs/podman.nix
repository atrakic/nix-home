{ pkgs, ... }:
{
  # Podman configuration for docker compatibility
  # On macOS, this enables docker-compose and docker CLI compatibility
  # The /var/run/docker.sock socket is automatically handled by podman-mac-helper (if available)
  
  # Note: podman and podman-compose are installed as packages in packages.nix
  # For full docker compatibility, ensure:
  # 1. podman socket service is running
  # 2. DOCKER_HOST environment variable can point to podman socket
  # 3. docker CLI commands are aliased/proxied to podman when needed
}
