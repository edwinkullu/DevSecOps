# ==============================================================================
# Terraform: Cloud Build triggers for POSTPILOT UAT CI/CD.
# ==============================================================================
locals {
  app_services = {
    brandkit-app = {
      repo  = "campaign-brandkit-app"
      image = "campaignbrandkitapp"
    }
    brandkit-node = {
      repo  = "campaign-brandkit-node"
      image = "campaignbrandkitnode"
    }
    creative-idea = {
      repo  = "creative-idea-ai"
      image = "creativeideaai"
    }
    user-identity = {
      repo  = "user-identity-app"
      image = "useridentityapp"
    }
    media-plan-app = {
      repo  = "media-plan-app"
      image = "mediaplanapp"
    }
    media-plan-node = {
      repo  = "media-plan-node"
      image = "mediaplannode"
    }
    activity-node = {
      repo  = "campaign-activity-node"
      image = "campaignactivitynode"
    }
    superadmin-app = {
      repo  = "superadmin-app"
      image = "superadminapp"
    }
    ai-service = {
      repo  = "ai-services"
      image = "aiservice"
    }
    postpilot-web = {
      repo  = "postpilot-website"
      image = "postpilotweb"
    }
  }

  cloudbuild_location = "us-central1"
  registry_url        = "me-central1-docker.pkg.dev/${var.project_id}/postpilot-uat"
  builder_image       = "${local.registry_url}/postpilot-builder"
  cicd_sa_email       = "${var.cicd_deployer_name}@${var.project_id}.iam.gserviceaccount.com"
  cicd_sa_resource    = "projects/${var.project_id}/serviceAccounts/${local.cicd_sa_email}"
}

/*
resource "google_cloudbuild_trigger" "app_ci_triggers" {
  for_each = local.app_services

  project  = var.project_id
  location = local.cloudbuild_location
  name     = "trigger-${each.key}-uat"

  service_account = local.cicd_sa_resource

  github {
    owner = "POSTPILOT-AI"
    name  = each.value.repo

    push {
      branch = "^main$"
    }
  }

  git_file_source {
    path      = "cloudbuild-ci.yaml"
    uri       = "https://github.com/POSTPILOT-AI/azure-infrastructure"
    repo_type = "GITHUB"
    revision  = "refs/heads/main"
  }

  substitutions = {
    _SERVICE_NAME  = each.key
    _IMAGE_NAME    = each.value.image
    _REGISTRY_URL  = local.registry_url
    _BUILDER_IMAGE = local.builder_image
  }
}
*/

resource "google_cloudbuild_trigger" "smart_cd_trigger" {
  project  = var.project_id
  location = local.cloudbuild_location
  name     = "uat-cd-deploy"

  service_account = local.cicd_sa_resource

  repository_event_config {
    repository = "projects/${var.project_id}/locations/us-central1/connections/postpilotgithub/repositories/POSTPILOT-AI-azure-infrastructure"
    push {
      branch = "^google_cloud$"
    }
  }

  # Only trigger CD if message starts with ci(svc): or ci(batch):
  filter = "commit.message.matches('^ci\\\\(.+\\\\):')"

  included_files = [
    "cloudbuild.yaml",
    "deploy-as-code/helm/**",
  ]

  ignored_files = [
    "**.md",
    "docs/**",
    "scripts/**",
    "*.png",
    "*.svg",
    ".gitignore",
  ]

  filename = "cloudbuild.yaml"

  substitutions = {
    _CLUSTER_NAME  = "postpilot-uat"
    _REGION        = "me-central1-a"
    _ENVIRONMENT   = "stage"
    _HELMFILE_ENV  = "uat"
    _DEPLOY_ALL    = "false"
    _BUILDER_IMAGE = local.builder_image
  }
}
