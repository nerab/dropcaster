Markdown pages are generated from the README.markdown etc. and then served my Jekyll. Therefore, after each change to the source files, we need to regenerate the pages using the following rake task:

    rake clobber web:generate

Run local test site:

    # http://jekyllrb.com/docs/github-pages/
    jekyll serve --baseurl ''
