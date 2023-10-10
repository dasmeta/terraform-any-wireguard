terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }

    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
  }

  required_version = ">= 1.3.0"
}

/**
 * set the following env vars so that aws provider will get authenticated before apply:

 export GOOGLE_APPLICATION_CREDENTIALS=xxxxxxxxxxxxxxxxxxxxxxxx
 export GOOGLE_REGION=xxxxxxxxxxxxxxxxxxxxxxxx
*/
provider "google" {
  region  = "europe-central2"
  zone    = "europe-central2-a"
  project = "playengine-live"
}
