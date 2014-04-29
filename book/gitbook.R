require(knitr)

#' Check if Gitbook is installed.
#' 
#' If Gitbook is not installed it will try to do so. If the installion fails or
#' Node.js is not installed, an error will be thrown.
checkForGitbook <- function() {
	if(system('npm', ignore.stdout=TRUE) != 0) {
		stop("Cannot find node.js. You can install it from http://nodejs.org/download/")
	}
	if(system('gitbook', ignore.stdout=TRUE) != 0) {
		message("Installing gitbook...")
		test <- system('npm install gitbook -g')
		if(test != 0) { stop(paste0("gitbook installation failed. Typically ", 
									"installing as root/Administrator works:\n",
									"  sudo npm install gitbook -g")) }
	}
	invisible(TRUE)
}

#' Initializes a new Gitbook.
#'
#' This will initalize a new Gitbook in the given directory. When done, it will
#' also change the working directory.
#' 
#' @author Jason Bryer <jason@bryer.org>
newGitbook <- function(dir) {
	# TODO: May want to make these parameters or options
	bookignore <- c('*.RMD','*.rmd','*.Rmd','log/','*.R','*.Rproj')
	gitignore <- c('.Rproj.user','_book/','.rmdbuild.Rda','*.DS_Store','log/','.Rhistory')
	summary.md <- c("# Summary","This is the summary of my book.",
					"",
					"* [section 1](section1/README.md)",
					"    * [example 1](section1/example1.md)",
					"    * [example 2](section1/example2.md)",
					"* [section 2](section2/README.md)",
					"    * [example 1](section2/example1.md)")
	readme.md <- c("# Book Title",
				   "#### by Your Name",
				   "",
				   "Replace with an introduction of your book.")
	
	if(missing(dir)) { stop('dir parameter is required.') }
	checkForGitbook()
	
	dir <- path.expand(dir)
	message(paste0('Creating ', dir))
	dir.create(dir, recursive=TRUE, showWarnings=FALSE)
	olddir <- setwd(dir)
	
	message('Writing .bookignore...')
	f <- file('.bookignore')
	writeLines(bookignore, f)
	close(f)
	
	message('Writing .gitignore...')
	f <- file('.gitignore')
	writeLines(gitignore, f)
	close(f)
	
	message('Writing README.md...')
	f <- file('README.md')
	writeLines(readme.md, f)
	close(f)
	
	message('Writing SUMMARY.md...')
	f <- file('SUMMARY.md')
	writeLines(summary.md, f)
	close(f)
	
	message(
'You can now open README.md and SUMMARY.md. Once you are done 
editting SUMMARY.md, initGitbook() will create the file and folder 
structure for your new Gitbook.')
}

#' Create files and folders based on contents of SUMMARY.md.
#' 
#' This first calls system command \code{gitbook init} but then will change
#' the all the file extensions from \code{.md} to \code{.Rmd} excluding
#' \code{SUMMARY.md} and \code{README.md}.
#' 
#' @param dir source directory for the Gitbook.
initGitbook <- function(dir=getwd()) {
	test <- system(paste0('gitbook init ', dir))
	if(test != 0) { stop("gitbook initalization failed") }
	mdfiles <- list.files(dir, '*.md', recursive=TRUE)
	mdfiles <- mdfiles[!mdfiles %in% c('README.md', 'SUMMARY.md')]
	mdfiles2 <- gsub('.md$', '.Rmd', mdfiles)
	file.rename(mdfiles, mdfiles2)
	invisible()
}

#' Builds markdown files from all Rmarkdown files in the given directories.
#' 
#' This function will build Rmarkdown files in the given directory to markdown.
#' The default is to traverse all subdirectories of the working directory
#' looking for .Rmd files to process. This function will save a file in the
#' working directory called \code{.rmdbuild.Rda} that contain the status of the
#' last successful build. This allows the function to only process changed files. 
#' 
#' @param dirs character vector of directors to process.
#' @param clean if TRUE, all Rmd files will be built regardless of their 
#'        modification date. 
#' @param log.dir if specified, the output from \code{\link{kintr}} will be saved
#'        to a log file in the given directory.
#' @param log.ext if log files are saved, the file extension to use.
#' @param ... other parameters.
#' @author Jason Bryer <jason@bryer.org>
buildRmd <- function(dirs = getwd(), clean=FALSE, log.dir, log.ext='.txt', ...) {
	if(!exists('statusfile')) {
		statusfile <- '.rmdbuild'
	}
	
	rmds <- list.files(dirs, '.rmd$', ignore.case=TRUE, recursive=TRUE)
	finfo <- file.info(rmds)
	
	if(!clean & file.exists(statusfile)) {
		load(statusfile)
		newfiles <- row.names(finfo)[!row.names(finfo) %in% row.names(rmdinfo)]
		existing <- row.names(finfo)[row.names(finfo) %in% row.names(rmdinfo)]
		existing <- existing[finfo[existing,]$mtime > rmdinfo[existing,]$mtime]
		rmds <- c(newfiles, existing)
	}
	
	for(j in rmds) {
		if(!missing(log.dir)) {
			logfile <- paste0(log.dir, '/', sub('.Rmd$', log.ext, j, ignore.case=TRUE))
			dir.create(dirname(logfile), recursive=TRUE, showWarnings=FALSE)
			sink(logfile)
		}
		oldwd <- setwd(dirname(j))
		tryCatch({
			knit(basename(j), sub('.Rmd$', '.md', basename(j), ignore.case=TRUE))
		}, finally={ setwd(oldwd) })
		if(!missing(log.dir)) { sink() }
	}
	
	rmdinfo <- finfo
	last.run <- Sys.time()
	last.R.version <- R.version
	save(rmdinfo, last.run, last.R.version, file=statusfile)
}

#' This will build a gitbook from the source markdown files.
#' 
#' This function is simply a wrapper to a system call to \code{gitbook}.
#' 
#' \url{https://github.com/GitbookIO/gitbook}
#' 
#' @param source.dir location containing the source files.
#' @param out.dir location of the built book.
#' @param format the format of book. Options are gitbook (default website book),
#'        pdf, or ebook.
#' @param title Name of the book to generate, defaults to repo name
#' @param intro Description of the book to generate
#' @param github ID of github repo like : username/repo
#' @param theme the book theme to use.
#' @author Jason Bryer <jason@bryer.org>
buildGitbook <- function(source.dir=getwd(),
					  out.dir=paste0(getwd(), '/_book'),
					  format, title, intro, github, theme) {
	cmd <- paste0("gitbook build ", source.dir, " --output=", out.dir)
	if(!missing(format)) { cmd <- paste0(cmd, " --format=", format) }
	if(!missing(title)) { cmd <- paste0(cmd, " --theme=", theme) }
	if(!missing(title)) { cmd <- paste0(cmd, ' --title="', title, '"') }
	if(!missing(intro)) { cmd <- paste0(cmd, ' --intro="', intro, '"') }
	if(!missing(github)) { cmd <- paste0(cmd, ' --github=', github) }
	if(!missing(theme)) { cmd <- paste0(cmd, " --theme=", theme) }
	system(cmd)
	
	# Post-process hack to fix broken img urls.
	# https://github.com/GitbookIO/gitbook/issues/99
	# Will also fix links to the Introduction
	# https://github.com/GitbookIO/gitbook/issues/113
	dirs <- list.dirs(out.dir, recursive=FALSE, full.names=FALSE)
	for(i in seq_along(dirs)) {
		files <- list.files(paste0(out.dir, '/', dirs[i]), '*.html')
		for(j in seq_along(files)) {
			fconn <- file(paste0(out.dir, '/', dirs[i], '/', files[j]))
			file <- readLines(fconn)
			close(fconn)
			file <- gsub(paste0(dirs[i], '/', dirs[i], '/'), '', file)
			file <- gsub('./">', './index.html">', file)
			fconn <- file(paste0(out.dir, '/', dirs[i], '/', files[j]))
			writeLines(file, fconn)
			close(fconn)
		}
	}
}

#' Open a built gitbook.
#' 
#' This function is a wrapper to the system call of \code{open} which should 
#' open the book in the system's default web browser.
#' 
#' @param out.dir location of the built gitbook.
#' @author Jason Bryer <jason@bryer.org>
openGitbook <- function(out.dir=paste0(getwd(), '/_book')) {
	browseURL(paste0(out.dir, '/index.html'))
}

#' Publish the built gitbook to Github.
#' 
#' Note that this is a wrapper to system \code{git} call.
#' 
#' This function assumes that the repository has already exists on Github.
#' 
#' Thanks to ramnathv for the shell script.
#' https://github.com/GitbookIO/gitbook/issues/106#issuecomment-40747887
#' 
#' @param repo the github repository. Should be of form username/repository
#' @param out.dir location of the built gitbook. 
#' @param message commit message.
#' @author Jason Bryer <jason@bryer.org>
publishGitbook <- function(repo, 
						   out.dir=paste0(getwd(), '/_book'),
						   message='Update built gitbook') {
	cmd <- paste0(
		"cd ", out.dir, " \n",
		"git init \n",
		"git commit --allow-empty -m '", message,"' \n",
		"git checkout -b gh-pages \n",
		"git add . \n",
		"git commit -am '", message, "' \n",
		"git push git@github.com:", repo, " gh-pages --force ")
	system(cmd)
}

#' Returns the version information about the currently installed gitbook and
#' what is avaialble from \url{https://www.npmjs.org/}.
#' 
#' @return a character vector with two elements, \code{installed.version} and
#'         \code{available.version}.
gitbook.info <- function() {
	checkForGitbook()
	installed <- system('gitbook --version', intern=TRUE)
	current <- system('npm view gitbook version', intern=TRUE)
	if(length(current) > 0) {
		current <- current[1]
		if(current == installed) {
			message(paste0('gitbook is up-to-date with version ', current))
		} else {
			message(paste0('A new version of gitbook is available. Version ',
						   installed, ' installed, ', current, ' available.'))
		}
	} else {
		warning(paste0('Could not get the current available version of gitbook.',
					   'Are you connected to the interent?'))
	}
	invisible(c(installed.version=installed, 
			    available.version=current))
}
