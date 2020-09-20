#' Prepare a repository to deploy an SER script on GitHub Actions
#'
#' Use this function inside of the {ser} repository. Add any additional
#' environmental variables under Settings > secrets in the GitHub UI for the
#' repository.
#'
#' @param script_name The name of the script, which should be included in
#'   `inst/scripts`
#' @param cron A cron job specification in include in the GitHub Action script
#'
#' @export
deploy_ghactions <- function(script_name, cron = "30 16 * * *") {
  if (!script_name %in% scripts_ls()) stop("script not found. Please add it to the ser package in `inst/scripts`.", call. = FALSE)

  if (!fs::dir_exists(".github/workflows/")) fs::dir_create(".github/workflows/")
  usethis::use_template(
    "main.yml",
    save_as = yml_file(script_name),
    package = "ser",
    data = list(
      name = workflow_name(script_name),
      script_name = script_name,
      cron = cron,
      DRIVE_AUTH_TOKEN_PATH = "${{ secrets.DRIVE_AUTH_TOKEN_PATH }}",
      GMAILR_APP = "${{ secrets.GMAILR_APP }}",
      SER_ACCESS_SECRET = "${{ secrets.SER_ACCESS_SECRET }}",
      SER_ACCESS_TOKEN = "${{ secrets.SER_ACCESS_TOKEN }}",
      SER_CONSUMER_KEY = "${{ secrets.SER_CONSUMER_KEY }}",
      SER_CONSUMER_SECRET = "${{ secrets.SER_CONSUMER_SECRET }}",
      cache_path = "${{ env.R_LIBS_USER }}",
      cache_key = "${{ hashFiles('.github/R-version') }}-1-${{ hashFiles('.github/depends.Rds') }}",
      cache_restore = "${{ hashFiles('.github/R-version') }}-1-"
    )
  )

  usethis::ui_info("Setting cron job to {cron}. Change the `cron` argument in {usethis::ui_field(yml_file(script_name))} to run at a different time.")
  usethis::ui_todo("Using the following secrets in the GitHub repository: \\
                   {usethis::ui_code('DRIVE_AUTH_TOKEN_PATH')},  \\
                   {usethis::ui_code('GMAILR_APP')},  \\
                   {usethis::ui_code('SER_ACCESS_SECRET')},  \\
                   {usethis::ui_code('SER_ACCESS_TOKEN')},  \\
                   {usethis::ui_code('SER_CONSUMER_SECRET')}")
  usethis::use_github_actions_badge(workflow_name(script_name))
  usethis::ui_todo("Commit and push changes to the  GitHub repository")
}

workflow_name <- function(script_name) {
  glue::glue("Deploy SER script: `{script_name}.R`")
}

yml_file <- function(script_name) {
  glue::glue(".github/workflows/{base_file_name(script_name)}.yml")
}

base_file_name <- function(x) {
  fs::path_ext_remove(fs::path_file(x))
}
