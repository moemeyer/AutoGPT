# AutoGPT Repository Synchronization Guide

**Repository**: moemeyer/AutoGPT  
**Target**: Sync with Significant-Gravitas/AutoGPT (upstream)  
**Date**: December 2, 2025

---

## Quick Status Check

Before proceeding, understand your current situation:

```bash
# Current position
Current fork: ~14,000 commits behind upstream
Last sync: ~2+ years ago (March 2023)
Upstream changes: Massive architectural overhaul
Fork viability: ❌ Not recommended to merge
```

---

## Recommended Approach: Fresh Start

Given the massive divergence, the cleanest approach is to start fresh with the latest upstream code.

### Prerequisites

Ensure you have installed:
- [x] Git (v2.30+)
- [x] Docker & Docker Compose (v20.10+)
- [x] Node.js (v16+) and npm (v8+)
- [x] VSCode or modern code editor
- [x] At least 10GB free disk space

---

## Step-by-Step Synchronization Process

### Step 1: Backup Your Current Work

First, preserve anything important from your current fork:

```bash
# Navigate to your local repository
cd /path/to/AutoGPT

# Create an archive branch
git checkout -b archive-fork-2025-12-02

# Push the archive
git push origin archive-fork-2025-12-02

# Create a tag for easy reference
git tag -a fork-backup-2025-12-02 -m "Backup before upstream sync"
git push origin fork-backup-2025-12-02
```

**Document any custom modifications:**
1. Review commit history for custom changes
2. Note any configuration modifications
3. Export any important data or results
4. Save any custom scripts or tools

### Step 2: Archive Current Fork on GitHub

Two options here:

#### Option A: Delete and Re-fork (Cleanest)
1. Go to your fork on GitHub: `https://github.com/moemeyer/AutoGPT`
2. Navigate to Settings → General → Danger Zone
3. Click "Delete this repository"
4. Confirm deletion
5. Go to upstream: `https://github.com/Significant-Gravitas/AutoGPT`
6. Click "Fork" button
7. Select your account
8. Wait for fork to complete

#### Option B: Hard Reset (Keeps Fork)
Keep the fork but reset it completely:

```bash
# Fetch latest from upstream
git fetch upstream

# Backup current branch (use main or master depending on your repo)
git branch archive-old-fork

# Reset to match upstream (replace 'master' with 'main' if needed)
git checkout master  # or: git checkout main
git reset --hard upstream/master  # or: upstream/main

# Force push (⚠️ This overwrites history!)
git push --force origin master  # or: origin/main

# Clean up old working branches if needed
# git branch -D <old-branch-name> 2>/dev/null || true
```

### Step 3: Clone Fresh Repository

```bash
# Remove old local repository (after backing up!)
cd ..
mv AutoGPT AutoGPT.backup

# Clone your fresh fork
git clone https://github.com/moemeyer/AutoGPT.git
cd AutoGPT

# Add upstream remote
git remote add upstream https://github.com/Significant-Gravitas/AutoGPT.git

# Verify remotes
git remote -v
```

Expected output:
```
origin    https://github.com/moemeyer/AutoGPT.git (fetch)
origin    https://github.com/moemeyer/AutoGPT.git (push)
upstream  https://github.com/Significant-Gravitas/AutoGPT.git (fetch)
upstream  https://github.com/Significant-Gravitas/AutoGPT.git (push)
```

### Step 4: Verify New Setup

```bash
# Check current status
git status

# View recent commits
git log --oneline -10

# Check branch
git branch -a
```

---

## Setting Up the Modern AutoGPT Platform

### Quick Setup (Recommended)

Use the official one-line installer:

**For macOS/Linux:**
```bash
curl -fsSL https://setup.agpt.co/install.sh -o install.sh
bash install.sh
```

**For Windows (PowerShell as Administrator):**
```powershell
powershell -c "iwr https://setup.agpt.co/install.bat -o install.bat; ./install.bat"
```

### Manual Setup

If you prefer manual control:

#### 1. Install Dependencies

**Check versions:**
```bash
docker --version          # Should be 20.10+
docker-compose --version  # Should be 2.0+
node --version           # Should be 16+
npm --version            # Should be 8+
git --version            # Should be 2.30+
```

#### 2. Configure Environment

```bash
# Navigate to the platform directory (if applicable)
cd autogpt_platform

# Copy environment template
cp .env.example .env

# Edit configuration
nano .env  # or your preferred editor
```

**Required environment variables:**
- `OPENAI_API_KEY` - Your OpenAI API key
- `ANTHROPIC_API_KEY` - Your Anthropic API key (optional)
- `DATABASE_URL` - Will be set by Docker
- `REDIS_URL` - Will be set by Docker

#### 3. Start Services

```bash
# Start with Docker Compose
docker-compose up -d

# Check services are running
docker-compose ps

# View logs
docker-compose logs -f
```

#### 4. Access Platform

Open your browser and navigate to:
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs

#### 5. Verify Installation

```bash
# Check backend health
curl http://localhost:8000/health

# Check frontend
curl http://localhost:3000
```

---

## Maintaining Sync with Upstream

### Set Up Automatic Sync

Create a GitHub Action workflow to keep your fork updated:

```yaml
# .github/workflows/sync-upstream.yml
name: Sync Fork with Upstream

on:
  schedule:
    # Run weekly on Mondays at 00:00 UTC
    - cron: '0 0 * * 1'
  workflow_dispatch:  # Allow manual trigger

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          
      - name: Sync with upstream
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git remote add upstream https://github.com/Significant-Gravitas/AutoGPT.git
          git fetch upstream
          git checkout master
          git merge upstream/master --no-edit
          git push origin master
```

### Manual Sync Process

Update your fork manually when needed:

```bash
# Fetch latest from upstream
git fetch upstream

# Checkout your master branch
git checkout master

# Merge upstream changes
git merge upstream/master

# Push to your fork
git push origin master
```

### Handle Conflicts

If conflicts occur:

```bash
# View conflicted files
git status

# Edit files to resolve conflicts
# Then add resolved files
git add <file>

# Continue merge
git merge --continue

# Push changes
git push origin master
```

---

## Migrating Custom Changes

If you had custom modifications in the old fork:

### 1. Identify Custom Changes

```bash
# Switch to backup branch
git checkout archive-fork-2025-12-02

# View your custom commits
git log --oneline --author="your-email@example.com"

# See changes in specific files
git diff upstream/master -- path/to/file
```

### 2. Create Feature Branch

```bash
# Switch back to master
git checkout master

# Create feature branch for your customizations
git checkout -b feature/migrate-custom-work
```

### 3. Apply Changes

**Option A: Cherry-pick commits**
```bash
# Cherry-pick specific commits from backup
git cherry-pick <commit-hash>
```

**Option B: Manual re-implementation**
1. Review old code
2. Re-implement in new structure
3. Use new platform capabilities where applicable
4. Follow new coding standards

### 4. Test and Submit

```bash
# Test your changes
npm test  # Frontend
poetry run pytest  # Backend (if using Python)

# Commit changes
git add .
git commit -m "feat: migrate custom modifications"

# Push to fork
git push origin feature/migrate-custom-work
```

---

## Best Practices Going Forward

### 1. Regular Updates
- Sync with upstream weekly/monthly
- Review changelog before merging
- Test after each sync

### 2. Branch Strategy
```
master          <- Always synced with upstream/master
develop         <- Your development branch
feature/*       <- Feature branches
hotfix/*        <- Urgent fixes
```

### 3. Keep Fork Clean
- Don't modify master directly
- Always work in feature branches
- Merge from upstream to master first
- Then merge master to your branches

### 4. Documentation
- Document your custom modifications
- Keep a CHANGELOG for your additions
- Update README if you add features

### 5. Enable GitHub Features
- **Dependabot**: Automatic dependency updates
- **CodeQL**: Security scanning
- **Actions**: CI/CD pipelines

---

## Troubleshooting

### "fatal: refusing to merge unrelated histories"

If you see this error:
```bash
git merge upstream/master --allow-unrelated-histories
```

### "Repository not found"

Check your remotes:
```bash
git remote -v
git remote set-url upstream https://github.com/Significant-Gravitas/AutoGPT.git
```

### Docker Issues

```bash
# Clean up Docker
docker-compose down -v
docker system prune -af

# Restart
docker-compose up -d
```

### Port Conflicts

If ports 3000 or 8000 are in use:
```bash
# Find process using port
lsof -ti:3000
lsof -ti:8000

# Kill process
kill -9 <PID>
```

---

## Getting Help

### Official Resources
- **Documentation**: https://docs.agpt.co
- **Discord**: https://discord.gg/autogpt
- **GitHub Issues**: https://github.com/Significant-Gravitas/AutoGPT/issues
- **Twitter**: https://twitter.com/Auto_GPT

### Before Asking for Help
1. Check documentation
2. Search existing issues
3. Review error logs
4. Provide minimal reproducible example

---

## Quick Reference Commands

```bash
# Sync with upstream
git fetch upstream && git merge upstream/master

# Update all submodules
git submodule update --init --recursive

# Clean workspace
git clean -fdx

# Reset to upstream
git reset --hard upstream/master

# Create backup
git branch backup-$(date +%Y%m%d)

# View difference with upstream
git diff upstream/master

# Check what would be merged
git log HEAD..upstream/master --oneline
```

---

## Conclusion

Following this guide will:
1. ✅ Bring your fork up to date with latest AutoGPT
2. ✅ Provide access to modern platform features  
3. ✅ Enable ongoing synchronization
4. ✅ Preserve your custom work (if needed)
5. ✅ Set up best practices going forward

**Estimated Time**: 4-6 hours for complete synchronization and setup

**Recommended Schedule**:
- Day 1: Backup and fresh clone (1-2 hours)
- Day 2: Platform setup and testing (2-3 hours)
- Day 3+: Custom migration if needed (variable)

---

**Good luck with your synchronization! 🚀**
