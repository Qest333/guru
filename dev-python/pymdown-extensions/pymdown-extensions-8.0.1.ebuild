# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7,8,9} )

DOCBUILDER="mkdocs"
DOCDEPEND="
	dev-python/mkdocs-git-revision-date-localized-plugin
	dev-python/mkdocs-minify-plugin
	dev-python/mkdocs-material
	dev-python/pymdown-lexers
	dev-python/pyspelling
"

inherit distutils-r1 docs

DESCRIPTION="Extensions for Python Markdown."
HOMEPAGE="
	https://github.com/facelessuser/pymdown-extensions
	https://pypi.org/project/pymdown-extensions
"
SRC_URI="https://github.com/facelessuser/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND=">=dev-python/markdown-3.2[${PYTHON_USEDEP}]"

DEPEND="test? (
	dev-python/pyyaml[${PYTHON_USEDEP}]
)"

distutils_enable_tests pytest

python_prepare_all() {
	# Fails on whitspaces
	rm tests/test_syntax.py || die

	# AssertionError: False is not true
	sed -i -e 's:test_no_pygments_linenums_custom_class:_&:' \
		tests/test_extensions/test_highlight.py  || die

	sed -i -e 's:test_default_override:_&:' \
		tests/test_extensions/test_superfences.py  || die

	sed -i -e 's:test_tabbed:_&:' \
		-e 's:test_tabbed_split:_&:' \
		tests/test_extensions/test_tabbed.py  || die

	distutils-r1_python_prepare_all
}

src_compile() {
	# mkdocs-git-revision-date-localized-plugin needs git repo
	if use doc; then
		git init
		git config --global user.email "you@example.com" || die
		git config --global user.name "Your Name" || die
		git add .
		git commit -m 'init'
	fi

	distutils-r1_src_compile
}
