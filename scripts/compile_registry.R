# compile_registry.R
# Reads registry/cards.yaml, writes dashboard/data/cards.json.
# Run from the project root (merian-data-dashboard/):
#   Rscript scripts/compile_registry.R

library(yaml)
library(jsonlite)

# Find the project root by walking up until we see registry/cards.yaml.
# Works whether the user runs from the project root, the scripts/ folder,
# or sources the file interactively.
find_root <- function(start = getwd()) {
  d <- normalizePath(start, mustWork = TRUE)
  repeat {
    if (file.exists(file.path(d, "registry", "cards.yaml"))) return(d)
    parent <- dirname(d)
    if (parent == d) stop("Could not find registry/cards.yaml above ", start)
    d <- parent
  }
}
root <- find_root()

reg <- yaml::read_yaml(file.path(root, "registry/cards.yaml"))

cards <- reg$cards

# minimal validation: every card has an id of the form clh-(br|nl)-NNNN
ok <- vapply(cards, function(c) grepl("^clh-(br|nl)-[0-9]{4}$", c$id), logical(1))
if (!all(ok)) stop("Bad ids: ", paste(sapply(cards[!ok], `[[`, "id"), collapse = ", "))

# Force list-shaped fields to stay JSON arrays even when they contain only one
# element (auto_unbox = TRUE would otherwise collapse them to scalars and break
# the dashboard renderer).
cards <- lapply(cards, function(c) {
  for (k in c("variables", "linkable_to")) {
    if (!is.null(c[[k]])) c[[k]] <- I(as.list(c[[k]]))
  }
  c
})

out <- list(
  generated_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"),
  version = "0.1.0",
  cards = cards
)

dir.create(file.path(root, "dashboard/data"), recursive = TRUE, showWarnings = FALSE)
jsonlite::write_json(out, file.path(root, "dashboard/data/cards.json"),
                     pretty = TRUE, auto_unbox = TRUE, null = "null")

# Inline the data straight into dashboard/index.html between markers, so the
# dashboard is a single self-contained file that opens with a double-click
# (no fetch / file:// CORS issues).
json_str  <- jsonlite::toJSON(out, pretty = TRUE, auto_unbox = TRUE, null = "null")
html_path <- file.path(root, "dashboard/index.html")
html      <- paste(readLines(html_path, warn = FALSE), collapse = "\n")
start_tag <- "// >>>MERIAN_DATA_START<<<"
end_tag   <- "// >>>MERIAN_DATA_END<<<"
i <- regexpr(start_tag, html, fixed = TRUE)
j <- regexpr(end_tag,   html, fixed = TRUE)
if (i < 0 || j < 0) {
  warning("MERIAN_DATA markers not found in index.html; data not inlined.")
} else {
  before   <- substr(html, 1, i - 1)
  after    <- substr(html, j + nchar(end_tag), nchar(html))
  new_html <- paste0(
    before,
    start_tag, "\nwindow.MERIAN_DATA = ", json_str, ";\n", end_tag,
    after
  )
  writeLines(new_html, html_path)
}

cat("Wrote", length(cards), "cards to dashboard/data/cards.json and inlined into dashboard/index.html\n")
