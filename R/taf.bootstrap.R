#' Bootstrap TAF Analysis
#'
#' Process metadata files \file{SOFTWARE.bib} and \file{DATA.bib} to set up
#' software and data files required for the analysis.
#'
#' @param software whether to process \verb{SOFTWARE.bib}.
#' @param data whether to process \verb{DATA.bib}.
#' @param clean whether to \code{\link{clean}} directories during the bootstrap
#'        procedure.
#' @param force whether to remove existing \verb{bootstrap/data},
#'        \verb{bootstrap/library}, and \verb{bootstrap/software} directories
#'        before the bootstrap procedure.
#' @param taf a convenience flag where \code{taf = TRUE} sets \code{software},
#'        \code{data}, \code{clean}, and \code{force} to \code{TRUE}, as is done
#'        on the TAF server. Any other value of \code{taf} is ignored.
#' @param quiet whether to suppress messages reporting progress.
#'
#' @details
#' If \code{clean = TRUE} then:
#' \enumerate{
#' \item \code{\link{clean.software}} and \code{\link{clean.library}} are run if
#'       \file{SOFTWARE.bib} is processed.
#' \item \code{\link{clean.data}} is run if \file{DATA.bib} is processed.
#' }
#'
#' The default behavior of \code{taf.bootstrap} is to skip downloading of remote
#' files (GitHub resources, URLs, bootstrap scripts) and also skip installing R
#' packages from GitHub if the files seem to be already in place. This is done
#' to speed up the bootstrap procedure as much as possible. To override this and
#' guarantee that all data and software files are updated, pass \code{force =
#' TRUE} to download and install everything declared in \verb{SOFTWARE.bib} and
#' \verb{DATA.bib}.
#'
#' @return Logical vector indicating which metadata files were processed.
#'
#' @note
#' This function should be called from the top directory of a TAF analysis. It
#' looks for a directory called \file{bootstrap} and prepares data files and
#' software according to metadata specifications.
#'
#' The bootstrap procedure consists of the following steps:
#' \enumerate{
#' \item If a \verb{bootstrap/SOFTWARE.bib} metadata file exists, it is
#'       processed.
#' \item If a \verb{bootstrap/DATA.bib} metadata file exists, it is processed.
#' }
#'
#' After the bootstrap procedure, software and data have been documented and
#' are ready to be used in the subsequent analysis. Specifically, the procedure
#' populates up to three new directories:
#' \itemize{
#' \item \verb{bootstrap/data} with data files.
#' \item \verb{bootstrap/library} with R packages compiled for the local
#'       platform.
#' \item \verb{bootstrap/software} with software files, such as R packages in
#'       \verb{tar.gz} source code format.
#' }
#'
#' Model settings and configuration files can be set up within \verb{DATA.bib},
#' see \href{https://github.com/ices-taf/doc/wiki/Bib-entries}{TAF Wiki}.
#'
#' @seealso
#' \code{\link{draft.data}} and \code{\link{draft.software}} can be used to
#' create initial draft versions of \file{DATA.bib} and \file{SOFTWARE.bib}
#' metadata files.
#'
#' \code{\link{taf.library}} loads a package from \verb{bootstrap/library}.
#'
#' \code{\link{icesTAF-package}} gives an overview of the package.
#'
#' @examples
#' \dontrun{
#' taf.bootstrap()
#' }
#'
#' @export

taf.bootstrap <- function(software=TRUE, data=TRUE, clean=TRUE, force=FALSE,
                          taf=NULL, quiet=FALSE)
{
  if (isTRUE(taf))
    software <- data <- clean <- force <- TRUE

  if (!dir.exists("bootstrap")) {
    warning(
      "'bootstrap' folder does not exists.\n",
      "Are you sure you are in the correct working directory?"
    )
    return(invisible(NULL)) # nothing to do
  }

  if (!quiet)
    msg("Bootstrap procedure running...")

  if (force)
    clean(c("bootstrap/software", "bootstrap/library", "bootstrap/data"))

  out <- list(SOFTWARE.bib = FALSE, DATA.bib = FALSE)

  ## 0  Process config
  if (dir.exists("bootstrap/initial/config"))
  {
    if (clean)
      clean("config")
    warning("'bootstrap/initial/config' is deprecated.\n",
            "Use DATA.bib entry instead.")
    cp("bootstrap/initial/config", "bootstrap")
  }

  ## 1  Process software
  if (software && file.exists("bootstrap/SOFTWARE.bib"))
  {
    out[["SOFTWARE.bib"]] <-
      process.bibfile(
        "software",
        clean = clean,
        quiet = quiet
      )
  }

  ## 2  Process data
  if (data && file.exists("bootstrap/DATA.bib"))
  {
    out[["DATA.bib"]] <-
      process.bibfile(
        "data",
        clean = clean,
        quiet = quiet
      )
  }

  ## Remove empty folders
  rmdir(c("bootstrap/data", "bootstrap/library", "bootstrap/software"), recursive = TRUE)
  rmdir("bootstrap/library:", recursive = TRUE) # this directory name can appear in Linux

  if (!quiet)
    msg("Bootstrap procedure done")

  invisible(out)
}
