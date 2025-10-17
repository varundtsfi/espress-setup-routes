#!/usr/bin/env bash

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Print colored output
print_step() {
    echo -e "\n${BLUE}===================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Validate prerequisites
check_prerequisites() {
    print_step "Checking Prerequisites"
    
    local all_ok=true
    
    if ! command_exists node; then
        print_error "Node.js is not installed. Please install Node.js 20.x or later."
        all_ok=false
    else
        node_version=$(node --version)
        print_success "Node.js $node_version is installed"
    fi
    
    if ! command_exists npm; then
        print_error "npm is not installed. Please install npm."
        all_ok=false
    else
        npm_version=$(npm --version)
        print_success "npm $npm_version is installed"
    fi
    
    if ! command_exists git; then
        print_error "git is not installed. Please install git."
        all_ok=false
    else
        git_version=$(git --version)
        print_success "$git_version is installed"
    fi
    
    if [ "$all_ok" = false ]; then
        print_error "Prerequisites check failed. Please install missing tools."
        exit 1
    fi
    
    print_success "All prerequisites are met"
}

# Get current branch name
get_branch_name() {
    local branch_name="${1:-}"
    
    if [ -z "$branch_name" ]; then
        if [ -n "${GITHUB_HEAD_REF:-}" ]; then
            branch_name="$GITHUB_HEAD_REF"
        elif [ -n "${GITHUB_REF_NAME:-}" ]; then
            branch_name="$GITHUB_REF_NAME"
        else
            branch_name=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
        fi
    fi
    
    echo "$branch_name"
}

# Validate branch name function
validate_branch_name() {
    local branch_name="$1"
    local task_ids_in_branch="PC|ID"
    local valid_branch_name_regex="^(remotes\/origin\/)?(development|main)$|(^(remotes\/origin\/)?feature|bugfix|enhancement|hotfix|feat|fix|refactor|chore|perf|docs|style)\/(($task_ids_in_branch)-[[:digit:]]+\/)([a-z0-9]-?)+[a-z0-9]$|(release\/v[12].[0-9]+.[0-9]+)$"
    
    if echo "$branch_name" | grep -qE "$valid_branch_name_regex"; then
        print_success "Branch name [$branch_name] is valid"
        return 0
    else
        print_error "Branch name [$branch_name] is not valid"
        print_warning "Valid branch name formats:"
        echo "  - main, development"
        echo "  - feature/PC-123/description"
        echo "  - bugfix/ID-456/fix-something"
        echo "  - hotfix/PC-789/urgent-fix"
        echo "  - release/v1.2.3 or release/v2.0.0"
        return 1
    fi
}

# Install dependencies
install_dependencies() {
    print_step "Installing Dependencies"
    
    if [ ! -d "node_modules" ]; then
        print_warning "node_modules directory not found. Running npm ci..."
        npm ci
        print_success "Dependencies installed successfully"
    else
        print_warning "node_modules exists. Checking if package-lock.json is up to date..."
        # Check if package-lock.json is newer than node_modules
        if [ "package-lock.json" -nt "node_modules" ]; then
            print_warning "package-lock.json is newer. Running npm ci..."
            npm ci
            print_success "Dependencies updated successfully"
        else
            print_success "Dependencies are up to date. Skipping installation."
        fi
    fi
}

# Run linting
run_lint() {
    print_step "Running Linting Checks"
    
    if ! npm run lint:check; then
        print_error "Linting failed. Please fix the issues and try again."
        return 1
    fi
    
    print_success "Linting passed successfully"
}

# Run formatting check
run_format_check() {
    print_step "Running Format Checks"
    
    if ! npm run format:check; then
        print_error "Format check failed. Run 'npm run format' to fix formatting issues."
        return 1
    fi
    
    print_success "Format check passed successfully"
}

# Validate branch name step
validate_branch() {
    print_step "Validating Branch Name"
    
    local branch_name
    branch_name=$(get_branch_name "${1:-}")
    
    if [ -z "$branch_name" ]; then
        print_error "Could not determine branch name"
        return 1
    fi
    
    echo "Current branch: $branch_name"
    
    if ! validate_branch_name "$branch_name"; then
        return 1
    fi
}

# Optional: Validate commit messages
validate_commits() {
    print_step "Validating Commit Messages (Optional)"
    
    if [ ! -f "commitlint.config.cjs" ] && [ ! -f ".commitlintrc.js" ]; then
        print_warning "commitlint config not found. Skipping commit message validation."
        return 0
    fi
    
    if ! command_exists npx; then
        print_warning "npx not available. Skipping commit message validation."
        return 0
    fi
    
    git fetch origin development &>/dev/null || true
    
    local current_branch
    current_branch=$(git branch --show-current)
    
    if [ "$current_branch" = "development" ] || [ "$current_branch" = "main" ]; then
        print_warning "On $current_branch branch. Skipping commit validation."
        return 0
    fi
    
    local no_of_commits
    no_of_commits=$(git rev-list --left-right --count origin/development..."$current_branch" 2>/dev/null | grep -oE '[[:digit:]]+' | tail -1 || echo "0")
    
    if [ "$no_of_commits" -eq 0 ]; then
        print_warning "No commits to validate"
        return 0
    fi
    
    echo "Validating $no_of_commits commit(s)..."
    
    if npx commitlint --from=HEAD~"$no_of_commits" --config commitlint.config.cjs; then
        print_success "Commit messages validation passed"
    else
        print_error "Commit messages validation failed"
        return 1
    fi
}

# Print summary
print_summary() {
    print_step "CI Validation Summary"
    
    if [ $1 -eq 0 ]; then
        print_success "All checks passed! ✓"
        echo -e "\n${GREEN}Your code is ready to be pushed!${NC}\n"
    else
        print_error "Some checks failed! ✗"
        echo -e "\n${RED}Please fix the issues before pushing.${NC}\n"
    fi
}

# Main execution
main() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     CI Validation Script - Local Testing      ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
    
    local exit_code=0
    local branch_name="${1:-}"
    local skip_install=false
    local validate_commits_flag=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-install)
                skip_install=true
                shift
                ;;
            --validate-commits)
                validate_commits_flag=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS] [BRANCH_NAME]"
                echo ""
                echo "Options:"
                echo "  --skip-install       Skip npm dependency installation"
                echo "  --validate-commits   Validate commit messages using commitlint"
                echo "  --help, -h           Show this help message"
                echo ""
                echo "Examples:"
                echo "  $0                                    # Run all checks on current branch"
                echo "  $0 feature/PC-123/my-feature         # Check specific branch name"
                echo "  $0 --skip-install                     # Skip dependency installation"
                echo "  $0 --validate-commits                 # Include commit message validation"
                exit 0
                ;;
            *)
                if [ -z "$branch_name" ]; then
                    branch_name="$1"
                fi
                shift
                ;;
        esac
    done
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not a git repository. Please run this script from the project root."
        exit 1
    fi
    
    # Run all checks
    check_prerequisites || exit_code=1
    
    if [ "$skip_install" = false ]; then
        install_dependencies || exit_code=1
    else
        print_warning "Skipping dependency installation (--skip-install flag)"
    fi
    
    run_lint || exit_code=1
    run_format_check || exit_code=1
    validate_branch "$branch_name" || exit_code=1
    
    if [ "$validate_commits_flag" = true ]; then
        validate_commits || exit_code=1
    fi
    
    print_summary $exit_code
    
    exit $exit_code
}

# Run main function with all arguments
main "$@"
