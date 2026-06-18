# resource "google_cloud_run_v2_service" "backend" {
#   name     = "bharath-fresh-backend"
#   location = "asia-south1"
#   ingress  = "INGRESS_TRAFFIC_ALL"

#   template {
#     containers {
#       image = "asia-south1-docker.pkg.dev/practiceproject-495412/new-project-repo/backend-image:latest"
#       resources {
#         limits = {
#           cpu    = "1"
#           memory = "512Mi"
#         }
#       }
#     }
#   }
# }

# resource "google_cloud_run_v2_service_iam_member" "public_access" {
#   project  = google_cloud_run_v2_service.backend.project
#   location = google_cloud_run_v2_service.backend.location
#   name     = google_cloud_run_v2_service.backend.name
#   role     = "roles/run.invoker"
#   member   = "allUsers"
# }
