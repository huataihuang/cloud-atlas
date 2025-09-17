# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

import sphinx_rtd_theme

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'Cloud Atlas: Discovery'
copyright = '2018 - now, Huatai Huang'
author = 'Huatai Huang'
release = 'beta'
version = '1.1'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
        'sphinx.ext.graphviz',
        'sphinxnotes.strike',
        'sphinxcontrib.youtube',
        'sphinxcontrib.video',
        'myst_parser'
]

# -- GraphViz configuration ----------------------------------
graphviz_output_format = 'svg'

templates_path = ['_templates']
exclude_patterns = []

language = 'zh'
html_search_language = 'zh'

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

#html_theme = 'alabaster'
html_theme = "sphinx_rtd_theme"
html_static_path = ['_static']
html_css_files = [
    'theme_overrides.css',
]
html_favicon = '_static/favicon.png'
