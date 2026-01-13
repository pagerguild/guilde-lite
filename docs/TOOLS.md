# Development Tools Reference

A comprehensive reference guide for all tools in the guilde-lite development environment. This setup uses a staged installation approach organized by functionality, plus a unified runtime manager for languages and development tools.

**Table of Contents:**
- [Stage 1: Core Foundation](#stage-1-core-foundation)
- [Stage 2: Modern CLI Tools](#stage-2-modern-cli-tools)
- [Stage 3: Terminal & Session Management](#stage-3-terminal--session-management)
- [Stage 4: Containers & Orchestration](#stage-4-containers--orchestration)
- [Stage 5: Database Clients](#stage-5-database-clients)
- [Stage 6: Cloud & AWS Tools](#stage-6-cloud--aws-tools)
- [Stage 7: AI Coding Tools](#stage-7-ai-coding-tools)
- [Stage 8: Security Tools](#stage-8-security-tools)
- [Stage 9: Build Tools](#stage-9-build-tools)
- [Runtimes & Language Tools](#runtimes--language-tools)

---

## Stage 1: Core Foundation

Essential tools needed for everything else. Install with: `brew bundle --file=brew/01-core.Brewfile`

### Git

**Version:** Latest (brew)
**Replaces:** N/A (native)
**Why:** Distributed version control, fundamental for all development

**Common Commands:**
```bash
git clone <repo-url>           # Clone a repository
git add <file>                 # Stage changes
git commit -m "message"        # Create commit
git push origin <branch>       # Push to remote
git pull origin <branch>       # Fetch and merge from remote
```

**Configuration Location:** `~/.gitconfig`, `~/.git-credentials`
**Official Documentation:** https://git-scm.com/doc

---

### Git LFS

**Version:** Latest (brew)
**Replaces:** N/A (addon to Git)
**Why:** Handle large binary files efficiently in Git repositories

**Common Commands:**
```bash
git lfs install                # Initialize LFS for user
git lfs track "*.psd"          # Track file type with LFS
git lfs ls-files                # List files tracked by LFS
git lfs migrate import --include="*.zip"  # Migrate existing files
```

**Configuration Location:** `.gitattributes` (per repo), `~/.gitconfig` (global settings)
**Official Documentation:** https://git-lfs.com

---

### GitHub CLI (gh)

**Version:** Latest (brew)
**Replaces:** Web interface for GitHub operations
**Why:** Manage GitHub repositories, PRs, and issues from CLI

**Common Commands:**
```bash
gh auth login                  # Authenticate with GitHub
gh repo create <name>          # Create new repository
gh pr create --title "title"   # Create pull request
gh issue list                  # List issues
gh release create v1.0.0       # Create release
```

**Configuration Location:** `~/.config/gh/config.yml`
**Official Documentation:** https://cli.github.com/manual

---

### Jujutsu (jj)

**Version:** Latest (brew)
**Replaces:** Git (optional, Git-compatible)
**Why:** Modern VCS with better UX - automatic rebasing, first-class conflict handling, working copy as commit

**Common Commands:**
```bash
jj git clone <repo-url>        # Clone a Git repository
jj new                         # Create new change
jj describe -m "message"       # Set commit message
jj git push                    # Push to remote
jj log                         # View commit graph
jj squash                      # Squash into parent
jj edit <rev>                  # Edit an older commit
jj undo                        # Undo last operation
```

**Key Features:**
- Working copy is always a commit (no staging area)
- Built-in undo/redo for all operations
- Automatic rebasing when editing history
- First-class conflict handling (conflicts are commits)
- Git-compatible (works with existing Git repos)

**Configuration Location:** `~/.config/jj/config.toml`
**Official Documentation:** https://martinvonz.github.io/jj

---

### Just

**Version:** Latest (brew)
**Replaces:** Make (for simple use cases)
**Why:** Simple command runner with better syntax than Make, no build system complexity

**Common Commands:**
```bash
just                           # List available recipes
just <recipe>                  # Run a recipe
just --list                    # Show all recipes with descriptions
just --choose                  # Interactively select a recipe
just --dry-run <recipe>        # Show what would run
```

**Example justfile:**
```just
# Build the project
build:
    cargo build --release

# Run tests
test:
    cargo test

# Deploy to production
deploy: build test
    ./deploy.sh
```

**Configuration Location:** `justfile` (project root)
**Official Documentation:** https://just.systems/man/en

---

### Mise

**Version:** Latest (brew)
**Replaces:** nvm, pyenv, goenv, rbenv, rustup, asdf
**Why:** Universal version manager for all languages and runtimes in one tool

**Common Commands:**
```bash
mise --version                 # Check mise version
mise install                   # Install tools defined in mise.toml
mise ls                        # List installed tools
mise use node@20               # Set Node version for current shell
mise sync                      # Sync installed tools with config
```

**Configuration Location:** `mise.toml` (project root), `~/.config/mise/config.toml` (global)
**Official Documentation:** https://mise.jdx.dev

---

### Task

**Version:** Latest (from go-task/tap)
**Replaces:** Make
**Why:** Modern task runner with simpler syntax and better task organization than Make

**Common Commands:**
```bash
task                           # List available tasks
task build                     # Run 'build' task
task install                   # Run 'install' task
task -l                        # List tasks in long format
task install docker            # Run 'install' with parameter
```

**Configuration Location:** `Taskfile.yml` (project root)
**Official Documentation:** https://taskfile.dev

---

## Stage 2: Modern CLI Tools

Native Rust/Go replacements for legacy Unix tools. Install with: `brew bundle --file=brew/02-cli.Brewfile`

### Starship

**Version:** Latest (brew)
**Replaces:** Bash/Zsh prompt customization
**Why:** Fast, customizable cross-shell prompt showing context (git, language versions, etc.)

**Common Commands:**
```bash
starship module battery        # Show battery module (macOS)
starship preset nerd-font-symbols  # Preview preset
# Usually configured via ~/.config/starship.toml (set in mise.toml)
```

**Configuration Location:** `~/.config/starship.toml`
**Official Documentation:** https://starship.rs

---

### Zoxide

**Version:** Latest (brew)
**Replaces:** cd command
**Why:** Smart directory jumping with frecency (frequently + recently used)

**Common Commands:**
```bash
z <dir-pattern>               # Jump to frequently used directory
z -                           # Go back to previous directory
zi                            # Interactive selection
zoxide query -l               # List all tracked directories
```

**Configuration Location:** `~/.local/share/zoxide/db.zo`
**Official Documentation:** https://github.com/ajeetdsouza/zoxide

---

### Ripgrep (rg)

**Version:** Latest (brew)
**Replaces:** grep
**Why:** Fast, recursive text search by default with smart ignore patterns

**Common Commands:**
```bash
rg "search-term"              # Search recursively in current dir
rg -i "term"                  # Case-insensitive search
rg --type py "pattern"        # Search Python files only
rg -C 3 "term"                # Show 3 lines of context
rg "term" /path/to/dir        # Search specific directory
```

**Configuration Location:** `~/.config/ripgreprc` (via config file)
**Official Documentation:** https://github.com/BurntSushi/ripgrep

---

### fd

**Version:** Latest (brew)
**Replaces:** find
**Why:** Simpler, faster, and more intuitive file finder with colors and ignore patterns

**Common Commands:**
```bash
fd "pattern"                  # Find files/dirs matching pattern
fd -e rs                      # Find files with .rs extension
fd "name" /path               # Search specific directory
fd --hidden "pattern"         # Include hidden files
fd -x ls -lh                  # Execute command on each result
```

**Configuration Location:** Configured via `.fdignore` files
**Official Documentation:** https://github.com/sharkdp/fd

---

### fzf

**Version:** Latest (brew)
**Replaces:** Manual file selection
**Why:** Fuzzy finder for interactive filtering of lists (files, git branches, history)

**Common Commands:**
```bash
fzf                           # Start interactive finder
history | fzf                 # Filter command history
git log --oneline | fzf       # Fuzzy select git commit
vim $(fzf)                    # Open file in editor via fzf
```

**Configuration Location:** `~/.config/fzf/fzfrc` or environment variables
**Official Documentation:** https://github.com/junegunn/fzf

---

### Bat

**Version:** Latest (brew)
**Replaces:** cat
**Why:** Syntax highlighting, line numbers, git integration, and paging

**Common Commands:**
```bash
bat file.rs                   # View file with syntax highlighting
cat file.rs | bat             # Pipe input with highlighting
bat -l rs file.txt            # Set language for unhighlighted file
bat -p file.rs                # Plain output (no decorations)
bat -A file.rs                # Show non-printing characters
```

**Configuration Location:** `~/.config/bat/config`
**Official Documentation:** https://github.com/sharkdp/bat

---

### Eza

**Version:** Latest (brew)
**Replaces:** ls
**Why:** Modern ls with colors, icons, git status, and better defaults

**Common Commands:**
```bash
eza                           # List directory
eza -l                        # Long format (equivalent to ls -la)
eza -l --git                  # Show git status for each file
eza -T                        # Tree view
eza -s modified               # Sort by modification time
```

**Configuration Location:** `~/.config/eza/config.toml`
**Official Documentation:** https://github.com/eza-community/eza

---

### Delta

**Version:** Latest (brew)
**Replaces:** git diff output
**Why:** Side-by-side diffs with syntax highlighting and improved readability

**Common Commands:**
```bash
git diff | delta              # Use delta for git diff (configure in .gitconfig)
delta --side-by-side file1 file2  # Side-by-side comparison
delta --line-numbers          # Show line numbers
# Usually integrated with git via gitconfig
```

**Configuration Location:** `~/.config/delta/delta.toml`, `~/.gitconfig`
**Official Documentation:** https://github.com/dandavison/delta

---

### sd

**Version:** Latest (brew)
**Replaces:** sed
**Why:** Simpler syntax for string replacement without regex gotchas

**Common Commands:**
```bash
sd "old" "new" file.txt       # Replace in file
sd -p "pattern" "replace"     # Preview replacements without applying
sd -i "old" "new"             # In-place replacement
sd --no-regex "literal"       # Literal string (not regex)
cat file | sd "old" "new"     # Pipe input
```

**Configuration Location:** Command-line only
**Official Documentation:** https://github.com/chmln/sd

---

### jq

**Version:** Latest (brew)
**Replaces:** Manual JSON processing
**Why:** Query and transform JSON with powerful filter language

**Common Commands:**
```bash
jq '.' file.json              # Pretty-print JSON
jq '.field' file.json         # Extract field
jq '.[] | select(.id > 5)'    # Filter array elements
jq 'keys' file.json           # Get object keys
curl api.example.com | jq '.'  # Process API responses
```

**Configuration Location:** `~/.jq` (startup file)
**Official Documentation:** https://stedolan.github.io/jq/manual/

---

### yq

**Version:** Latest (brew)
**Replaces:** Manual YAML processing
**Why:** Query and transform YAML similar to jq

**Common Commands:**
```bash
yq '.' file.yaml              # Pretty-print YAML
yq '.spec.containers[0].image' file.yaml  # Extract nested value
yq -i '.metadata.name = "new"' file.yaml  # In-place edit
yq 'keys' file.yaml           # Get object keys
```

**Configuration Location:** Command-line only
**Official Documentation:** https://github.com/mikefarah/yq

---

### Dust

**Version:** Latest (brew)
**Replaces:** du
**Why:** Faster, interactive disk usage visualization

**Common Commands:**
```bash
dust                          # Show disk usage in current dir
dust -d 3                     # Limit depth to 3 levels
dust /path/to/analyze         # Analyze specific directory
dust -r                       # Reverse sort (largest last)
```

**Configuration Location:** Command-line only
**Official Documentation:** https://github.com/bootandy/dust

---

### duf

**Version:** Latest (brew)
**Replaces:** df
**Why:** Better formatted disk free information

**Common Commands:**
```bash
duf                           # Show all mounted filesystems
duf /                         # Show space for root filesystem
duf -a                        # Show all filesystems including pseudo
duf -o size                   # Sort by size
```

**Configuration Location:** Command-line only
**Official Documentation:** https://github.com/muesli/duf

---

### Procs

**Version:** Latest (brew)
**Replaces:** ps
**Why:** More modern process listing with colors and better defaults

**Common Commands:**
```bash
procs                         # List processes
procs rust                    # Find processes matching "rust"
procs --tree                  # Show process tree
procs --watch                 # Watch processes (like top)
procs --pids 1234             # Show specific process
```

**Configuration Location:** `~/.config/procs/config.toml`
**Official Documentation:** https://github.com/dalance/procs

---

### Bottom

**Version:** Latest (brew)
**Replaces:** top, htop
**Why:** Modern system monitor with better UI and information layout

**Common Commands:**
```bash
bottom                        # Start system monitor
btm                           # Shorter command
btm -r 100                    # Set refresh rate (milliseconds)
btm --hide-time               # Hide time widget
```

**Configuration Location:** `~/.config/bottom/bottom.toml`
**Official Documentation:** https://github.com/ClementtsaC/bottom

---

### Hyperfine

**Version:** Latest (brew)
**Replaces:** Manual benchmarking
**Why:** Statistical benchmarking of commands/scripts

**Common Commands:**
```bash
hyperfine 'command1' 'command2'  # Compare two commands
hyperfine -r 100 'command'      # Run 100 times
hyperfine --show-output 'cmd'   # Show command output
hyperfine 'cmd' --export-json results.json  # Export results
```

**Configuration Location:** Command-line only
**Official Documentation:** https://github.com/sharkdp/hyperfine

---

### Tokei

**Version:** Latest (brew)
**Replaces:** Manual code counting
**Why:** Count lines of code, comments, blanks across languages

**Common Commands:**
```bash
tokei                         # Analyze current directory
tokei .                       # Same as above
tokei -l                      # List supported languages
tokei src/                    # Analyze specific directory
tokei --files                 # Show per-file statistics
```

**Configuration Location:** Command-line only
**Official Documentation:** https://github.com/XAMPPRocky/tokei

---

### xh

**Version:** Latest (brew)
**Replaces:** curl
**Why:** curl alternative with simpler syntax and better defaults

**Common Commands:**
```bash
xh GET https://httpbin.org/get  # GET request
xh POST https://api.example.com name=value  # POST with params
xh --headers                  # Show response headers only
xh --pretty=all               # Pretty-print output
xh --auth user:pass GET url   # Basic authentication
```

**Configuration Location:** `~/.config/xh/config.toml`
**Official Documentation:** https://github.com/ducaale/xh

---

## Stage 3: Terminal & Session Management

Terminal emulator and session multiplexer. Install with: `brew bundle --file=brew/03-terminal.Brewfile`

### Ghostty

**Version:** Latest (cask)
**Replaces:** Terminal.app, iTerm2
**Why:** GPU-accelerated terminal with modern features, excellent performance

**Common Commands:**
```bash
# Terminal is usually started from Applications menu
ghostty --working-directory /path  # Start in specific directory
# Configure via ~/.config/ghostty/config (TOML format)
```

**Configuration Location:** `~/.config/ghostty/config`
**Official Documentation:** https://ghostty.org

---

### Font: JetBrains Mono Nerd Font

**Version:** Latest (cask from homebrew/cask-fonts)
**Why:** Monospace font with Nerd Font icons for terminal UI elements

**Common Usage:**
```bash
# Set in terminal preferences as default font
# Size: 12-14pt typically works well
```

**Configuration Location:** Terminal preferences
**Official Documentation:** https://www.nerdfonts.com, https://www.jetbrains.com/lp/mono/

---

### Font: Fira Code Nerd Font

**Version:** Latest (cask from homebrew/cask-fonts)
**Why:** Alternative monospace font with ligatures support

**Common Usage:**
```bash
# Set in terminal/editor preferences as default font
# Enables programming ligatures: =>, <=, :=, etc.
```

**Configuration Location:** Terminal/editor preferences
**Official Documentation:** https://github.com/tonsky/FiraCode

---

### Tmux

**Version:** Latest (brew)
**Replaces:** Terminal tabs/windows
**Why:** Terminal multiplexer for session management, window splitting, detach/reattach

**Common Commands:**
```bash
tmux new-session -s session-name  # Create new session
tmux attach -t session-name       # Attach to session
tmux ls                           # List sessions
tmux kill-session -t session-name # Kill session

# Inside tmux (default prefix: Ctrl+B)
Ctrl+B c                         # Create new window
Ctrl+B n/p                       # Next/previous window
Ctrl+B "                         # Split horizontally
Ctrl+B %                         # Split vertically
Ctrl+B d                         # Detach from session
```

**Configuration Location:** `~/.tmux.conf`
**Official Documentation:** https://github.com/tmux/tmux/wiki

---

### Zellij

**Version:** Latest (brew)
**Replaces:** Tmux (alternative, optional)
**Why:** Modern tmux alternative with better defaults and layout management

**Common Commands:**
```bash
zellij                        # Start new session
zellij attach session-name    # Attach to session
zellij ls                     # List sessions
zellij kill-session -s name   # Kill session

# Inside zellij (default prefix: Ctrl+G)
Ctrl+G c                      # Create new pane
Ctrl+G r                      # Enter resize mode
Ctrl+G x                      # Close pane
Ctrl+G d                      # Detach
```

**Configuration Location:** `~/.config/zellij/config.kdl`
**Official Documentation:** https://zellij.dev

---

## Stage 4: Containers & Orchestration

Docker alternative and Kubernetes tools. Install with: `brew bundle --file=brew/04-containers.Brewfile`

### OrbStack

**Version:** Latest (cask)
**Replaces:** Docker Desktop
**Why:** Lightweight Docker and Kubernetes engine, saves ~4GB RAM vs Docker Desktop

**Common Commands:**
```bash
docker ps                     # List running containers
docker run -it image-name     # Run container interactively
docker build -t image-name .  # Build image from Dockerfile
orbctl                        # OrbStack specific commands
```

**Configuration Location:** Environment: `DOCKER_HOST = unix://~/.orbstack/run/docker.sock`
**Official Documentation:** https://orbstack.dev

---

### lazydocker

**Version:** Latest (brew)
**Replaces:** Docker CLI for management
**Why:** TUI for Docker container and image management

**Common Commands:**
```bash
lazydocker                    # Start interactive Docker manager
# Navigation: arrow keys, ENTER to select, Ctrl+C to exit
# View logs, exec commands, manage containers visually
```

**Configuration Location:** `~/.config/lazydocker/config.yml`
**Official Documentation:** https://github.com/jesseduffield/lazydocker

---

### kubectl

**Version:** Latest (brew)
**Replaces:** N/A (native Kubernetes CLI)
**Why:** Command-line interface to Kubernetes clusters

**Common Commands:**
```bash
kubectl cluster-info          # Show cluster info
kubectl get nodes             # List nodes
kubectl get pods              # List pods
kubectl describe pod pod-name # Get pod details
kubectl logs pod-name         # Show pod logs
kubectl exec -it pod-name -- bash  # Execute command in pod
```

**Configuration Location:** `~/.kube/config`
**Official Documentation:** https://kubernetes.io/docs/reference/kubectl/

---

### kubectx

**Version:** Latest (brew)
**Replaces:** Manual context switching
**Why:** Quickly switch between Kubernetes clusters and namespaces

**Common Commands:**
```bash
kubectx                       # List and switch contexts interactively
kubectx context-name          # Switch to specific context
kubectx -c                    # Show current context
kubens                        # Switch namespaces
kubens -c                     # Show current namespace
```

**Configuration Location:** `~/.kube/config`
**Official Documentation:** https://github.com/ahmetb/kubectx

---

### Helm

**Version:** Latest (brew)
**Replaces:** Manual Kubernetes manifests
**Why:** Package manager for Kubernetes applications

**Common Commands:**
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami  # Add chart repo
helm search repo bitnami/postgresql  # Search for charts
helm install release-name bitnami/postgresql  # Install chart
helm list                     # List releases
helm upgrade release-name chart  # Upgrade release
helm uninstall release-name   # Uninstall release
```

**Configuration Location:** `~/.helm/`, `~/.kube/config`
**Official Documentation:** https://helm.sh/docs/

---

### k9s

**Version:** Latest (brew)
**Replaces:** kubectl CLI for management
**Why:** TUI for Kubernetes cluster management and troubleshooting

**Common Commands:**
```bash
k9s                           # Start interactive Kubernetes manager
# Navigation: arrow keys, ENTER to select, ? for help
# View pods, logs, exec, port-forward, etc. visually
```

**Configuration Location:** `~/.config/k9s/`
**Official Documentation:** https://k9scli.io

---

## Stage 5: Database Clients

CLI tools for database access. Install with: `brew bundle --file=brew/05-databases.Brewfile`

### PostgreSQL@16

**Version:** 16.x (brew)
**Replaces:** N/A (database client)
**Why:** psql client for connecting to PostgreSQL databases

**Common Commands:**
```bash
psql -U username -d database_name  # Connect to database
psql -l                            # List databases
psql -c "SELECT * FROM table"      # Execute query
psql -f script.sql                 # Run SQL file
psql -d db -h hostname -U user     # Connect to remote database
```

**Configuration Location:** `~/.pgpass`, `~/.psqlrc`
**Official Documentation:** https://www.postgresql.org/docs/16/app-psql.html

---

### libpq

**Version:** Latest (brew)
**Replaces:** N/A (dependency)
**Why:** PostgreSQL C library required by many tools and languages

**Common Usage:**
```bash
# Used as dependency for:
# - psql (PostgreSQL client)
# - psycopg2 (Python PostgreSQL driver)
# - node-postgres (Node.js driver)
# No direct CLI usage
```

**Configuration Location:** `~/.libpq` settings
**Official Documentation:** https://www.postgresql.org/docs/16/libpq.html

---

### Redis

**Version:** Latest (brew)
**Replaces:** N/A (database client)
**Why:** redis-cli client for connecting to Redis servers

**Common Commands:**
```bash
redis-cli                     # Connect to local Redis
redis-cli -h hostname -p 6379  # Connect to remote Redis
redis-cli PING                # Test connection
redis-cli GET key             # Get value
redis-cli SET key value       # Set key-value
redis-cli KEYS "*"            # List keys
redis-cli FLUSHDB             # Clear database
redis-cli --help              # Show commands
```

**Configuration Location:** Redis server config (different from client)
**Official Documentation:** https://redis.io/commands/

---

## Stage 6: Cloud & AWS Tools

AWS CLI and modern authentication. Install with: `brew bundle --file=brew/06-cloud.Brewfile`

### AWS CLI

**Version:** Latest (brew)
**Replaces:** N/A (AWS command-line interface)
**Why:** Official CLI for AWS services management

**Common Commands:**
```bash
aws s3 ls                     # List S3 buckets
aws s3 cp file s3://bucket/   # Upload to S3
aws ec2 describe-instances    # List EC2 instances
aws sts get-caller-identity   # Check current credentials
aws --version                 # Show version
aws configure                 # Configure credentials (legacy, use Granted)
```

**Configuration Location:** `~/.aws/credentials`, `~/.aws/config`
**Official Documentation:** https://docs.aws.amazon.com/cli/latest/userguide/

---

### Granted

**Version:** Latest (from common-fate/granted tap)
**Replaces:** AWS CLI configure, assume-role workflows
**Why:** Fast AWS role/account switching with SSO support

**Common Commands:**
```bash
granted                       # List available roles and switch interactively
assume role-name              # Assume specific role
granted --version             # Show version
granted list                  # List available roles
granted browser               # Open AWS console with assumed role
```

**Configuration Location:** `~/.config/granted`, `~/.aws/config`
**Official Documentation:** https://granted.dev

---

### session-manager-plugin

**Version:** Latest (brew)
**Replaces:** SSH with key pairs
**Why:** SSH into EC2 instances via AWS Systems Manager without SSH keys

**Common Commands:**
```bash
aws ssm start-session --target i-1234567890abcdef0  # Start session
# Usually paired with aws-cli and Granted
# Managed via AWS IAM policies
```

**Configuration Location:** AWS Systems Manager agent on instances
**Official Documentation:** https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html

---

## Stage 7: AI Coding Tools

AI-assisted development tools. Install with: `brew bundle --file=brew/07-ai.Brewfile`

### Cursor

**Version:** Latest (cask)
**Replaces:** VS Code (extended)
**Why:** AI-native code editor based on VS Code with integrated AI assistance

**Common Commands:**
```bash
cursor .                      # Open current directory in Cursor
cursor file.py                # Open specific file
cursor --new-window           # Open in new window
# Use Cmd+K for AI chat, Cmd+L for inline edit
```

**Configuration Location:** `~/.config/Cursor/`, VS Code settings migration available
**Official Documentation:** https://cursor.com

---

### Claude Code (npm package)

**Version:** Latest (via mise - npm package)
**Replaces:** N/A (Anthropic CLI assistant)
**Why:** Command-line interface to Claude for code generation and analysis

**Common Commands:**
```bash
claude --help                 # Show available commands
claude --version              # Check installed version
claude                        # Start interactive session
# Requires ANTHROPIC_API_KEY environment variable
```

**Configuration Location:** `~/.claude/settings.json`, environment variables
**Official Documentation:** https://docs.anthropic.com/claude-code

---

## Stage 8: Security Tools

Encryption, secrets management, scanning. Install with: `brew bundle --file=brew/08-security.Brewfile`

### age

**Version:** Latest (brew)
**Replaces:** GPG for simple encryption
**Why:** Modern, simpler encryption tool for files and secrets

**Common Commands:**
```bash
age -o file.txt.age file.txt  # Encrypt file (public key)
age -d -i key.txt file.txt.age > file.txt  # Decrypt file
age-keygen                    # Generate key pair
age -e -i key.txt file.txt    # Encrypt with secret key
```

**Configuration Location:** Key files typically in `~/.config/age/`
**Official Documentation:** https://github.com/FiloSottile/age

---

### sops

**Version:** Latest (brew)
**Replaces:** Manual secrets management
**Why:** Encrypted YAML/JSON/ENV secrets management with multiple encryption backends

**Common Commands:**
```bash
sops secrets.yaml             # Edit encrypted file
sops -d secrets.yaml          # Decrypt and view
sops -e --input-type json file.json > encrypted.json  # Encrypt JSON
sops --rotate secrets.yaml    # Rotate encryption keys
```

**Configuration Location:** `.sops.yaml` (encryption rules)
**Official Documentation:** https://github.com/mozilla/sops

---

### cosign

**Version:** Latest (brew)
**Replaces:** Manual container image signing
**Why:** Sign and verify container image signatures (Sigstore)

**Common Commands:**
```bash
cosign generate-key-pair      # Generate signing key
cosign sign image:tag         # Sign container image
cosign verify --key cosign.pub image:tag  # Verify signature
cosign attach attestation --attestation attestation.json image:tag
```

**Configuration Location:** Key files, Sigstore configuration
**Official Documentation:** https://docs.sigstore.dev/cosign/

---

### Trivy

**Version:** Latest (brew)
**Replaces:** Manual vulnerability scanning
**Why:** Comprehensive vulnerability scanner for containers, images, and code

**Common Commands:**
```bash
trivy image image:tag         # Scan container image
trivy config .                # Scan configuration files
trivy fs .                    # Scan filesystem
trivy vuln db download        # Update vulnerability database
trivy report --format json output.json  # Export scan results
```

**Configuration Location:** `~/.trivy/`
**Official Documentation:** https://github.com/aquasecurity/trivy

---

## Stage 9: Build Tools

Compilers, linters, build systems. Install with: `brew bundle --file=brew/09-build.Brewfile`

### golangci-lint

**Version:** Latest (brew)
**Replaces:** Individual Go linters
**Why:** Aggregated Go linter running multiple linters in parallel

**Common Commands:**
```bash
golangci-lint run             # Run all linters on current directory
golangci-lint run ./...       # Run on all packages
golangci-lint linters         # List available linters
golangci-lint help            # Show help
.golangci.yml                 # Configuration file
```

**Configuration Location:** `.golangci.yml` (project root), `~/.golangci.yml` (home)
**Official Documentation:** https://golangci-lint.run

---

### CMake

**Version:** Latest (brew)
**Replaces:** Manual build configuration
**Why:** Cross-platform build system generator for C/C++ projects

**Common Commands:**
```bash
cmake -B build                # Generate build files
cmake --build build           # Build project
cmake --install build         # Install built artifacts
cmake -DCMAKE_BUILD_TYPE=Release -B build  # Release build
ctest                         # Run tests
```

**Configuration Location:** `CMakeLists.txt` (project files)
**Official Documentation:** https://cmake.org/documentation/

---

### Ninja

**Version:** Latest (brew)
**Replaces:** Make (build executor)
**Why:** Fast build system executor, used by CMake for parallel builds

**Common Commands:**
```bash
ninja                         # Build using build.ninja
ninja -C build                # Build in specific directory
ninja install                 # Install targets
ninja -j 4                    # Parallel build with 4 jobs
# Usually invoked via CMake: cmake --build build
```

**Configuration Location:** `build.ninja` (generated)
**Official Documentation:** https://ninja-build.org

---

### ccache

**Version:** Latest (brew)
**Replaces:** N/A (compiler cache)
**Why:** Compiler result caching for faster rebuilds

**Common Commands:**
```bash
ccache --version              # Check version
ccache -s                     # Show cache stats
ccache -z                     # Clear cache
ccache -M 5G                  # Set cache size
# Automatically used when CC=ccache gcc, CXX=ccache g++
```

**Configuration Location:** `~/.ccache/ccache.conf`
**Official Documentation:** https://ccache.dev

---

## Runtimes & Language Tools

Universal version management via Mise. Configure in `mise.toml` at project root.

### Go

**Version:** 1.23 (configured in mise.toml)
**Replaces:** Manual Go installation
**Why:** Primary language for orchestration, CLI tools, agents

**Common Commands:**
```bash
go version                    # Check version
go run main.go                # Run Go file
go build -o binary .          # Build executable
go test ./...                 # Run tests
go mod tidy                   # Manage dependencies
go install github.com/user/project@latest  # Install CLI tool
```

**Configuration Location:** `go.mod`, `go.sum` (per project), `GOPATH=~/go`
**Official Documentation:** https://golang.org/doc/

---

### Rust

**Version:** latest (configured in mise.toml)
**Replaces:** Manual Rust installation
**Why:** Systems programming, performance-critical code

**Common Commands:**
```bash
rustc --version               # Check version
cargo new project             # Create new Rust project
cargo build                   # Build project
cargo test                    # Run tests
cargo run                     # Build and run
cargo add dependency          # Add dependency
```

**Configuration Location:** `Cargo.toml`, `Cargo.lock` (per project)
**Official Documentation:** https://www.rust-lang.org/documentation.html

---

### Python

**Version:** 3.12 (configured in mise.toml)
**Replaces:** Manual Python installation
**Why:** AI/ML, scripting, data processing

**Common Commands:**
```bash
python --version              # Check version
python -m venv venv           # Create virtual environment (use uv instead)
python script.py              # Run script
python -m pip install package # Install package (use uv instead)
uv pip install package        # Install with UV (faster)
```

**Configuration Location:** `pyproject.toml`, `.python-version`, virtualenv directory
**Official Documentation:** https://www.python.org/

---

### Node.js

**Version:** lts (configured in mise.toml)
**Replaces:** Manual Node installation
**Why:** Legacy tooling compatibility

**Common Commands:**
```bash
node --version                # Check version
node script.js                # Run script
npm install                   # Install dependencies
npm run build                 # Run npm script
npx package-name              # Run package without installing
```

**Configuration Location:** `package.json`, `package-lock.json`
**Official Documentation:** https://nodejs.org/en/docs/

---

### Bun

**Version:** latest (configured in mise.toml)
**Replaces:** Node.js/npm (drop-in replacement)
**Why:** Faster JavaScript runtime with bundler, test runner, and package manager

**Common Commands:**
```bash
bun --version                 # Check version
bun run script.ts             # Run TypeScript/JavaScript
bun install                   # Install dependencies (faster than npm)
bun build src/index.ts        # Bundle project
bun test                      # Run tests
bun add package               # Add dependency
```

**Configuration Location:** `package.json`, `bunfig.toml` (optional)
**Official Documentation:** https://bun.sh/docs

---

### Astral UV

**Version:** latest (configured in mise.toml)
**Replaces:** pip, pip-tools, virtualenv (10-100x faster)
**Why:** High-performance Python package manager and environment manager

**Common Commands:**
```bash
uv --version                  # Check version
uv venv                       # Create virtual environment
uv pip install package        # Install package
uv pip list                   # List installed packages
uv pip freeze > requirements.txt  # Export dependencies
uv lock                       # Create lock file
uv sync                       # Sync environment from lock file
```

**Configuration Location:** `pyproject.toml`, `uv.lock`
**Official Documentation:** https://docs.astral.sh/uv/

---

### Terraform

**Version:** latest (configured in mise.toml)
**Replaces:** Manual infrastructure provisioning
**Why:** Infrastructure as Code for cloud resources

**Common Commands:**
```bash
terraform init                # Initialize Terraform working directory
terraform plan                # Show planned changes
terraform apply               # Apply changes
terraform destroy             # Destroy infrastructure
terraform validate            # Validate configuration
terraform fmt                 # Format configuration files
```

**Configuration Location:** `.tf` files, `.terraform/` directory, `terraform.tfstate`
**Official Documentation:** https://www.terraform.io/docs/

---

### Deno

**Version:** latest (configured in mise.toml)
**Replaces:** Node.js (alternative)
**Why:** Secure JavaScript/TypeScript runtime without node_modules

**Common Commands:**
```bash
deno --version                # Check version
deno run script.ts            # Run TypeScript
deno cache deps.ts            # Cache dependencies
deno fmt                      # Format code
deno lint                     # Lint code
deno bundle script.ts output.js  # Bundle script
```

**Configuration Location:** `deno.json`, `deno.lock`
**Official Documentation:** https://deno.land/manual/

---

### Mypy

**Version:** latest (via pipx via mise)
**Replaces:** N/A (Python type checker)
**Why:** Static type checking for Python

**Common Commands:**
```bash
mypy file.py                  # Type check file
mypy --strict file.py         # Strict type checking
mypy --ignore-missing-imports file.py  # Ignore missing stubs
# Installed via: pipx:mypy in mise.toml
```

**Configuration Location:** `mypy.ini`, `pyproject.toml [tool.mypy]`
**Official Documentation:** https://mypy.readthedocs.io/

---

### Ruff

**Version:** latest (via pipx via mise)
**Replaces:** flake8, black, isort (unified linter + formatter)
**Why:** Fast Python linter and formatter in one tool

**Common Commands:**
```bash
ruff check file.py            # Lint file
ruff format file.py           # Format file
ruff check --fix .            # Fix issues automatically
ruff --version                # Check version
# Installed via: pipx:ruff in mise.toml
```

**Configuration Location:** `pyproject.toml [tool.ruff]`, `ruff.toml`
**Official Documentation:** https://docs.astral.sh/ruff/

---

### SkyPilot

**Version:** latest[aws] (via pipx via mise)
**Replaces:** Manual cloud compute setup
**Why:** Cloud compute orchestration for distributed training and workloads

**Common Commands:**
```bash
sky launch --cpus 16 task.yaml  # Launch task on cloud
sky jobs status                 # Check job status
sky jobs logs job_id            # View logs
sky stop job_id                 # Stop job
# Installed via: pipx:skypilot[aws] in mise.toml
```

**Configuration Location:** YAML task files, `~/.sky/`
**Official Documentation:** https://skypilot.readthedocs.io/

---

## Environment Variables

Set globally in `mise.toml [env]` section:

| Variable | Value | Purpose |
|----------|-------|---------|
| `GO111MODULE` | `on` | Enable Go modules |
| `GOPATH` | `~/go` | Go workspace directory |
| `GOBIN` | `~/go/bin` | Go binary installation directory |
| `UV_PYTHON_PREFERENCE` | `only-managed` | Use only mise-managed Python |
| `PYTHONDONTWRITEBYTECODE` | `1` | Don't create .pyc files |
| `EDITOR` | `cursor --wait` | Default editor (Cursor) |
| `VISUAL` | `cursor --wait` | Visual editor (Cursor) |
| `HOMEBREW_NO_ANALYTICS` | `1` | Disable Homebrew analytics |
| `HOMEBREW_NO_ENV_HINTS` | `1` | Disable Homebrew environment hints |
| `DOCKER_HOST` | `unix://~/.orbstack/run/docker.sock` | OrbStack Docker socket |
| `XDG_CONFIG_HOME` | `~/.config` | Config directory (XDG standard) |
| `XDG_DATA_HOME` | `~/.local/share` | Data directory (XDG standard) |
| `XDG_CACHE_HOME` | `~/.cache` | Cache directory (XDG standard) |
| `XDG_STATE_HOME` | `~/.local/state` | State directory (XDG standard) |

---

## Installation & Management

### Install All Stages

```bash
# Install one stage at a time:
brew bundle --file=brew/01-core.Brewfile
brew bundle --file=brew/02-cli.Brewfile
brew bundle --file=brew/03-terminal.Brewfile
# ... etc for each stage

# Or use a task runner:
task setup:brew
```

### Update Tools

```bash
# Update all Homebrew tools
brew upgrade

# Update all runtimes (Mise)
mise sync
mise upgrade
```

### Configure Development Environment

```bash
# Ensure all runtimes are installed
mise install

# Verify installations
git --version
mise --version
task --version
# ... etc for each tool
```

### Quick Reference: What Replaces What

| Legacy Tool | Modern Replacement | Why |
|-------------|-------------------|-----|
| grep | ripgrep (rg) | 2-3x faster with better defaults |
| find | fd | Simpler syntax, respects .gitignore |
| ls | eza | Colors, icons, git integration |
| cat | bat | Syntax highlighting, paging |
| du | dust | Interactive visualization |
| df | duf | Better formatting |
| ps | procs | Colors, better defaults |
| top/htop | bottom | Modern UI |
| sed | sd | Simpler regex syntax |
| curl | xh | Simpler HTTP client |
| Make | task | Better syntax, task organization |
| cd | zoxide | Smart directory jumping |
| nvm/pyenv/goenv | mise | Single tool for all languages |
| Docker Desktop | OrbStack | Less RAM usage, same features |
| GPG | age | Simpler encryption |
| tmux | zellij | Modern terminal multiplexer |

---

## Troubleshooting & Common Issues

### Tool Not Found After Installation

```bash
# Restart shell to reload PATH
exec $SHELL

# Or verify installation
which tool-name
# or
tool-name --version
```

### Mise Tools Not Available

```bash
# Ensure tools are installed
mise install

# Load the current shell
eval "$(mise activate)"
```

### Docker/OrbStack Issues

```bash
# Verify Docker socket
echo $DOCKER_HOST
# Should be: unix://~/.orbstack/run/docker.sock

# Test connection
docker ps
```

### Python/UV Issues

```bash
# Ensure UV prefers managed Python
echo $UV_PYTHON_PREFERENCE
# Should be: only-managed

# Create new environment
uv venv
source .venv/bin/activate
```

---

## Additional Resources

- **Configuration Files**: See `.gitconfig`, `.tmux.conf`, `.zshrc` for examples
- **Task Automation**: See `Taskfile.yml` for available development tasks
- **Runtime Version Pinning**: See `mise.toml` for current versions
- **Homebrew Bundles**: See `brew/` directory for stage definitions

---

**Last Updated:** 2026-01-13
**Mise Version:** Latest (homebrew-core)
**Homebrew Version:** Latest

For tool-specific configuration and advanced usage, refer to official documentation links in each section.
