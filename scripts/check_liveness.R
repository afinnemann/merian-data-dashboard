# check_liveness.R
# Pings every card's `url` and writes dashboard/data/status.json with HTTP status per id.
# Run: Rscript scripts/check_liveness.R

library(yaml)
library(httr2)
library(jsonlite)

reg <- yaml::read_yaml("registry/cards.yaml")

check_one <- function(card) {
  resp <- tryCatch(
    httr2::request(card$url) |>
      httr2::req_method("HEAD") |>
      httr2::req_timeout(8) |>
      httr2::req_error(is_error = \(r) FALSE) |>
      httr2::req_perform(),
    error = function(e) NULL
  )
  list(
    id = card$id,
    url = card$url,
    status = if (is.null(resp)) "unreachable" else as.character(resp$status_code),
    checked_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z")
  )
}

results <- lapply(reg$cards, check_one)

out <- list(
  generated_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"),
  results = results
)

dir.create("dashboard/data", recursive = TRUE, showWarnings = FALSE)
jsonlite::write_json(out, "dashboard/data/status.json",
                     pretty = TRUE, auto_unbox = TRUE)

cat("Wrote liveness status for", length(results), "cards\n")
