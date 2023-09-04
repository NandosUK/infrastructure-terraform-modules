# Nando's Terraform Modules

<img src="assets/tfnandos.png" alt="Terraform" width="300"/>

## Description

This repository contains Terraform modules for various infrastructure components. We use `semantic-release` to manage versioning and releases.
This repo doesn't contain any information specific to Nando's.

# Usage

You can find specific examples and available variables inside [each module folder](gcp). Here is an example on how to use cloud run v1 module:

```hcl
module "cloud-run-api-my-awesome-api" {
  source                = "github.com/NandosUK/infrastructure/terraform-modules/gcp/cloud-run-v1"
  project_id                 = "my-gcp-project-id"
  name                       = "my-awesome-api"
  (...)
}
```

## Examples

You can find specific implementation examples under the [test](test) folder.

## Which API should I use?

### 1. API Cloud Run

[Example](test/cloud-run-v2.tf)

<img src="assets/api_1_run.png" />

This is a good starting point to build any API that supports

- Load Balancer
- Cloud Armor Policy support
- Custom domain on `https://MY_API.api.nandos.services`
- Error monitoring
- Cloud Secret support
- Custom Env variables
- Custom Release strategy

### 2. API Gateway

[Example](test/cloud-run-v2.tf)

<img src="assets/api_2_run.png" />

If your api needs extra features like Okta Authentication, Service key authentication use this api.
Note: You still need to create your resources with API Cloud Run above and reference its urls in the swagger docs.

#### When To Use

-
- **Security Features:**
  - When working with Google-specific services, like validating Google ID tokens or using built-in OpenID Connect and OAuth Consent flows provided in GCP.
  - For basic JWT validation.
- **Traffic Management:** For basic per-project, per-minute quotas.

### 3. Apigee

- [Example Proxy Creation](https://github.com/NandosUK/infrastructure/blob/master/gcp/mgt-apigee/environment/inputs-for-deployments.auto.tfvars)
- [Example Backstage Proxy Creation](https://backstage.nandos.dev/create/templates/default/custom-api-template)

<img src="assets/api_3_run.png" />

#### When To Use

- Multitenant APIs
- API used by 3rd parties
- Use custom transformations
- API needs advanced quota limits
- Connect to internal /external API / System + complex transformation (XML -> JSON, etc)

#### Resources

- [apigee-publish](https://github.com/NandosUK/infrastructure/tree/master/apigee/apigee-publish)
- [Proxies](https://github.com/NandosUK/infrastructure/blob/master/gcp/mgt-apigee/environment/inputs-for-deployments.auto.tfvars)
- [Hall Of Flame: Apigee Kubernetes Stack Tutorial](https://nandosuk.atlassian.net/wiki/spaces/CORE/pages/3716907010/Hall+Of+Flame%3A+Apigee+Kubernetes+Stack+Tutorial?search_id=ae1dc135-725f-482a-b3cc-66dfba3dffb6)
- [Hall Of Flame: Apigee Cloud Run Stack Tutorial](https://nandosuk.atlassian.net/wiki/spaces/CORE/pages/3665690669/Hall+Of+Flame+Apigee+Cloud+Run+Stack+Tutorial)

# Contribute

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
