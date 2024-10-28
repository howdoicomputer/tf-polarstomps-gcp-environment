terraform {
  required_version = ">=1.3"

  required_providers {
    google = {
      source = "hashicorp/google"
      # Workaround for https://github.com/hashicorp/terraform-provider-google/issues/19428
      version = ">= 5.40.0, != 5.44.0, != 6.2.0, != 6.3.0, < 7"
    }
  }
}
