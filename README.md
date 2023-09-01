# Nando's Terraform Modules
![Alt text](assets/tflogo.png)
## Description

This repository contains Terraform modules for various infrastructure components. We use `semantic-release` to manage versioning and releases.

## Semantic Release and Commit Message Guidelines

This project uses [semantic-release](https://github.com/semantic-release/semantic-release) for automated versioning and package publishing. To ensure that the version numbers are updated correctly, we adhere to [Conventional Commits](https://www.conventionalcommits.org/) guidelines for commit messages.

### Commit Message Format

The commit message should be structured as follows:

```bash
<type>(<scope>): <subject>
```

- **Type** : Indicates the type of change being made. This can be one of the following:
  - `feat`: A new feature
  - `fix`: A bug fix
  - `chore`: Routine tasks or maintenance
  - `docs`: Documentation changes
  - `style`: Code style changes (formatting, indentation, etc.)
  - `refactor`: Code changes that neither fix bugs nor add features
  - `perf`: Performance improvements
  - `test`: Adding or modifying tests
- **Scope** : An optional part that indicates the module or part of the codebase the commit modifies. Specify the individual terraform module.
- **Subject** : A short description of the change. Keep it concise and to the point.

#### Examples

- `feat(api): add new validation logic`
- `fix(cloud-run-v1): resolve issue with variable x`
- `chore(tests): add additional unit tests for utils`
- `docs(cloud-function-v1): update setup instructions`

### How to Make Commits

1. Make your changes in a new git branch:

```bash

git checkout -b my-fix-branch main
```

2. Commit your changes using a descriptive commit message that follows our commit message guidelines.

```bash
git commit -m "fix(auth): resolve login bug"
```

3. Push your branch to GitHub:

```bash
git push origin my-fix-branch
```

4. If you have pushed commits up to GitHub, you can use the GitHub UI to create a new Pull Request targeting the `main` branch.
