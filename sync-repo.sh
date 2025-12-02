#!/bin/bash
# AutoGPT Repository Synchronization Script
# This script helps sync the moemeyer/AutoGPT fork with upstream

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Display banner
echo -e "${GREEN}"
cat << "EOF"
    ___         __       ______________ ______
   /   | __  __/ /_____  / ____/ __ \  /_  __/
  / /| |/ / / / __/ __ \/ / __/ /_/ / / / / 
 / ___ / /_/ / /_/ /_/ / /_/ / ____/ / / /  
/_/  |_\__,_/\__/\____/\____/_/     /_/     
                                             
Repository Synchronization Script
EOF
echo -e "${NC}"

print_info "Starting AutoGPT repository synchronization process..."
echo ""

# Step 1: Check prerequisites
print_info "Step 1: Checking prerequisites..."

if ! command_exists git; then
    print_error "Git is not installed. Please install Git first."
    exit 1
fi
print_success "Git is installed ($(git --version))"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not in a git repository. Please run this script from the AutoGPT directory."
    exit 1
fi
print_success "Inside a git repository"

echo ""

# Step 2: Check current state
print_info "Step 2: Analyzing current repository state..."

CURRENT_BRANCH=$(git branch --show-current)
print_info "Current branch: $CURRENT_BRANCH"

# Check if upstream remote exists
if ! git remote | grep -q "^upstream$"; then
    print_warning "Upstream remote not found. Adding it now..."
    git remote add upstream https://github.com/Significant-Gravitas/AutoGPT.git
    print_success "Added upstream remote"
else
    print_success "Upstream remote exists"
fi

echo ""

# Step 3: Fetch latest from upstream
print_info "Step 3: Fetching latest changes from upstream..."
print_info "This may take a few minutes..."

if git fetch upstream; then
    print_success "Successfully fetched from upstream"
else
    print_error "Failed to fetch from upstream"
    exit 1
fi

echo ""

# Step 4: Show comparison
print_info "Step 4: Analyzing differences with upstream..."

# Detect default branch name (master or main)
DEFAULT_BRANCH=$(git remote show upstream 2>/dev/null | grep 'HEAD branch' | cut -d' ' -f5)
if [ -z "$DEFAULT_BRANCH" ]; then
    DEFAULT_BRANCH="master"
fi

COMMITS_BEHIND=$(git rev-list --count HEAD..upstream/$DEFAULT_BRANCH 2>/dev/null || echo "unknown")
COMMITS_AHEAD=$(git rev-list --count upstream/$DEFAULT_BRANCH..HEAD 2>/dev/null || echo "unknown")

print_info "Your fork is:"
echo -e "  - ${RED}$COMMITS_BEHIND commits behind${NC} upstream/$DEFAULT_BRANCH"
echo -e "  - ${YELLOW}$COMMITS_AHEAD commits ahead${NC} of upstream/$DEFAULT_BRANCH"

echo ""

# Step 5: Offer synchronization options
print_warning "IMPORTANT: This fork has diverged significantly from upstream."
print_warning "The upstream repository has undergone a complete architectural rewrite."
echo ""

print_info "Synchronization Options:"
echo ""
echo "  1) Create backup and show manual sync instructions (RECOMMENDED)"
echo "  2) Hard reset to upstream/master (⚠️  DESTROYS fork history)"
echo "  3) Attempt merge (⚠️  NOT RECOMMENDED - will have conflicts)"
echo "  4) Exit without changes"
echo ""

read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        print_info "Creating backup and preparing instructions..."
        
        # Create backup branch
        BACKUP_BRANCH="backup-$(date +%Y%m%d-%H%M%S)"
        git branch "$BACKUP_BRANCH"
        print_success "Created backup branch: $BACKUP_BRANCH"
        
        echo ""
        print_info "=== MANUAL SYNCHRONIZATION INSTRUCTIONS ==="
        echo ""
        print_info "Your current state has been backed up to: $BACKUP_BRANCH"
        echo ""
        print_info "To complete synchronization manually:"
        echo ""
        echo "  1. Review the analysis documents:"
        echo "     - REPOSITORY_REVIEW_ANALYSIS.md"
        echo "     - SYNC_GUIDE.md"
        echo "     - README_REVIEW.md"
        echo ""
        echo "  2. Backup important data from your fork"
        echo ""
        echo "  3. Option A - Fork reset (cleanest):"
        echo "     - Delete your fork on GitHub"
        echo "     - Re-fork from Significant-Gravitas/AutoGPT"
        echo "     - Clone the new fork"
        echo ""
        echo "  4. Option B - Hard reset (keeps fork):"
        echo "     git checkout master"
        echo "     git reset --hard upstream/master"
        echo "     git push --force origin master"
        echo ""
        echo "  5. Follow SYNC_GUIDE.md for detailed setup"
        echo ""
        print_success "Backup created. Review documentation before proceeding."
        ;;
        
    2)
        print_warning "⚠️  WARNING: This will RESET your repository to match upstream!"
        print_warning "⚠️  All fork-specific changes will be LOST!"
        echo ""
        read -p "Are you ABSOLUTELY sure? Type 'yes' to confirm: " confirm
        
        if [ "$confirm" = "yes" ]; then
            # Create backup first
            BACKUP_BRANCH="backup-before-reset-$(date +%Y%m%d-%H%M%S)"
            git branch "$BACKUP_BRANCH"
            print_success "Created safety backup: $BACKUP_BRANCH"
            
            print_info "Resetting to upstream/$DEFAULT_BRANCH..."
            git checkout $DEFAULT_BRANCH 2>/dev/null || git checkout -b $DEFAULT_BRANCH
            git reset --hard upstream/$DEFAULT_BRANCH
            print_success "Repository reset to upstream/$DEFAULT_BRANCH"
            
            print_warning "To complete sync, you need to force push:"
            echo "  git push --force origin $DEFAULT_BRANCH"
            print_warning "This requires proper GitHub authentication"
        else
            print_info "Reset cancelled."
        fi
        ;;
        
    3)
        print_warning "⚠️  Attempting merge - expect MANY conflicts!"
        read -p "Continue? (yes/no): " confirm
        
        if [ "$confirm" = "yes" ]; then
            # Create backup
            BACKUP_BRANCH="backup-before-merge-$(date +%Y%m%d-%H%M%S)"
            git branch "$BACKUP_BRANCH"
            print_success "Created backup: $BACKUP_BRANCH"
            
            print_info "Attempting merge..."
            if git merge upstream/$DEFAULT_BRANCH --no-edit; then
                print_success "Merge completed successfully!"
            else
                print_error "Merge has conflicts. Resolve them and run:"
                echo "  git add ."
                echo "  git merge --continue"
            fi
        else
            print_info "Merge cancelled."
        fi
        ;;
        
    4)
        print_info "Exiting without changes."
        exit 0
        ;;
        
    *)
        print_error "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
print_success "Script completed!"
print_info "Next steps:"
echo "  1. Review the created documentation"
echo "  2. Follow SYNC_GUIDE.md for detailed instructions"
echo "  3. Set up the modern AutoGPT platform"
echo "  4. Configure automatic upstream sync"
echo ""
print_info "For help, see: README_REVIEW.md"
