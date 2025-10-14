# Express Setup Routes

A Node.js Express application with automated CI/CD pipeline for code quality checks.

## 🚀 Features

- **Automated Linting**: ESLint with Airbnb configuration
- **Code Formatting**: Prettier for consistent code style
- **Branch Name Validation**: Enforces branch naming conventions
- **Continuous Integration**: GitHub Actions workflow for automated checks
- **Node.js 20**: Built with the latest LTS version

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** 20.x or higher
- **npm** 10.x or higher
- **Git**

### Check Your Versions

```bash
node -v  # Should show v20.x.x
npm -v   # Should show 10.x.x
```

### Upgrading Node.js

If you need to upgrade Node.js:

**Using nvm (Recommended):**
```bash
nvm install 20
nvm use 20
nvm alias default 20
```

**Using fnm:**
```bash
fnm install 20
fnm use 20
fnm default 20
```

## 🛠️ Installation

1. **Clone the repository:**
```bash
git clone https://github.com/varundtsfi/espress-setup-routes.git
cd espress-setup-routes
```

2. **Install dependencies:**
```bash
npm install
```

3. **Verify installation:**
```bash
npm ci
```

## 📜 Available Scripts

| Script | Description |
|--------|-------------|
| `npm run lint:check` | Check for linting errors |
| `npm run lint:fix` | Auto-fix linting errors |
| `npm run format:check` | Check code formatting |
| `npm run format:fix` | Auto-format code |
| `npm run validate-branch-name` | Validate current branch name |

## 🔄 GitHub Actions CI/CD

### Workflow Overview

The project uses GitHub Actions for continuous integration. The workflow runs on:

- **Pull Requests** to `main` or `development` branches
- **Direct pushes** to `main` or `development` branches

### Workflow Steps

1. ✅ **Checkout repository**
2. ✅ **Setup Node.js 20.x**
3. ✅ **Install dependencies**
4. ✅ **Lint codebase**
5. ✅ **Format check**
6. ✅ **Validate branch name**

### Setting Up the Workflow

The workflow is already configured in `.github/workflows/nodejs-ci.yml`. To set it up in a new repository:

1. **Create the workflow directory:**
```bash
mkdir -p .github/workflows
```

2. **Create the workflow file:**
```bash
touch .github/workflows/nodejs-ci.yml
```

3. **Add the configuration:**

```yaml
name: Node.js CI
permissions: read-all
env:
  NODE_ENV: development
  BRANCH_NAME: ${{ github.head_ref || github.ref_name }}
on:
  pull_request:
    types: [opened, synchronize, reopened]
    branches: [main, development]
  push:
    branches:
      - main
      - development
jobs:
  Lint-and-format-test-ubuntu:
    name: check for linting and formatting errors on ubuntu-latest
    runs-on: ubuntu-latest
    defaults:
      run:
        shell: bash
    strategy:
      matrix:
        node-version: [20.x]
    steps:
      - name: Check out repo
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Use Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
      - name: Install Dependencies
        run: npm ci
      - name: Lint Codebase
        run: npm run lint:check
      - name: Format Codebase
        run: npm run format:check
      - name: Validate Branch name
        run: npm run validate-branch-name $BRANCH_NAME
```

4. **Commit and push:**
```bash
git add .github/workflows/nodejs-ci.yml
git commit -m "chore: add GitHub Actions CI workflow"
git push
```

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. ESLint Version Conflict

**Error:**
```
ERESOLVE could not resolve
eslint-config-airbnb-base requires eslint ^7.32.0 || ^8.2.0
```

**Solution:**
```bash
npm install --save-dev eslint@^8.57.0
```

#### 2. Node.js Version Warnings

**Error:**
```
EBADENGINE Unsupported engine
required: { node: '>=20' }
current: { node: 'v18.x.x' }
```

**Solution:** Upgrade to Node.js 20:
```bash
nvm install 20
nvm use 20
```

#### 3. Package Lock Corruption

**Error:**
```
404 Not Found - GET https://registry.npmjs.org/synckit/-/synckit-0.11.9.tgz
```

**Solution:**
```bash
rm package-lock.json
npm cache clean --force
npm install
git add package-lock.json
git commit -m "fix: regenerate package-lock.json"
git push
```

#### 4. Git Push Rejected

**Error:**
```
! [rejected] development -> development (fetch first)
```

**Solution:**
```bash
git pull origin development
git push origin development
```

#### 5. Merge Conflicts on GitHub

When you see merge conflicts in the GitHub web interface:

1. Click **"Accept current change"** for the desired version
2. Click **"Mark as resolved"**
3. Click **"Commit merge"**

## 🌿 Branch Naming Convention

This project enforces branch naming conventions. Valid branch name patterns:

- `feature/*` - New features
- `fix/*` - Bug fixes
- `hotfix/*` - Critical fixes
- `chore/*` - Maintenance tasks
- `docs/*` - Documentation updates
- `refactor/*` - Code refactoring
- `test/*` - Test updates

**Example:**
```bash
git checkout -b feature/add-user-authentication
git checkout -b fix/resolve-login-bug
```

## 📦 Dependencies

### Main Dependencies

- **express** - Web framework
- Other production dependencies listed in `package.json`

### Dev Dependencies

- **eslint** - Linting utility
- **eslint-config-airbnb-base** - Airbnb style guide
- **prettier** - Code formatter
- **lint-staged** - Pre-commit linting
- **commander** - Command-line interface

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Commit Message Convention

Follow conventional commits format:

- `feat:` - New features
- `fix:` - Bug fixes
- `chore:` - Maintenance tasks
- `docs:` - Documentation updates
- `refactor:` - Code refactoring
- `test:` - Test updates

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

- **Varun** - [varundtsfi](https://github.com/varundtsfi)

## 🙏 Acknowledgments

- Airbnb for the ESLint configuration
- The Node.js and Express communities
- GitHub Actions for CI/CD automation

## 📞 Support

If you encounter any issues:

1. Check the [Troubleshooting](#-troubleshooting) section
2. Search existing [GitHub Issues](https://github.com/varundtsfi/espress-setup-routes/issues)
3. Create a new issue with detailed information

---

**Note:** Make sure to run `npm install` after pulling the latest changes to keep your dependencies up to date.
