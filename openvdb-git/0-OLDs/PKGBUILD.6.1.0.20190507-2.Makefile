# Maintainer: Name <name@fai.com>

pkgname=openvdb-git
pkgver=6.1.0.20190507
pkgrel=2
_ver_release="6.1.0"
_name_release="openvdb-${_ver_release}"
pkgdesc="A large suite of tools for the efficient storage and manipulation of sparse volumetric data discretized on three-dimensional grids"
arch=('x86_64')
url="https://github.com/AcademySoftwareFoundation/openvdb"
license=('MPL')
depends=('boost-libs' 'openexr' 'ilmbase' 'intel-tbb'
         'blosc' 'zlib'
         'jemalloc'
         'glfw-x11' 'glu'
)
makedepends=('boost' 'mesa' 'chrpath')
conflicts=('openvdb')
provides=('openvdb')
source=("OpenVDB-v${_ver_release}.tar.gz"
)
sha256sums=('d8803214c245cf0ca14a2c30cd215b183147c03c888c59fc642f213f98b4d68f'
)

prepare() {
  cd "${_name_release}/openvdb"

  sed -i  -e "/^DESTDIR := /c\DESTDIR := ${pkgdir}/usr" \
          -e "/^BOOST_INCL_DIR := /c\BOOST_INCL_DIR := /usr/include/boost" \
          -e "/^BOOST_LIB_DIR := /c\BOOST_LIB_DIR := /usr/lib" \
          -e "/^EXR_INCL_DIR := /c\EXR_INCL_DIR := /usr/include/OpenEXR" \
          -e "/^EXR_LIB_DIR := /c\EXR_LIB_DIR := /usr/lib" \
          -e "/^ILMBASE_INCL_DIR := /c\ILMBASE_INCL_DIR := /usr/include/OpenEXR" \
          -e "/^ILMBASE_LIB_DIR := /c\ILMBASE_LIB_DIR := /usr/lib" \
          -e "/^TBB_INCL_DIR := /c\TBB_INCL_DIR := /usr/include/tbb" \
          -e "/^TBB_LIB_DIR := /c\TBB_LIB_DIR := /usr/lib" \
          -e "/^BLOSC_INCL_DIR := /c\BLOSC_INCL_DIR := /usr/include" \
          -e "/^BLOSC_LIB_DIR := /c\BLOSC_LIB_DIR := /usr/lib" \
          -e "/^BLOSC_LIB := /c\BLOSC_LIB := -lblosc -lz" \
          -e "/^CONCURRENT_MALLOC_LIB_DIR := /c\CONCURRENT_MALLOC_LIB_DIR := /usr/lib" \
          -e "/^CPPUNIT_INCL_DIR := /c\CPPUNIT_INCL_DIR :=" \
          -e "/^CPPUNIT_LIB_DIR := /c\CPPUNIT_LIB_DIR :=" \
          -e "/^CPPUNIT_LIB := /c\CPPUNIT_LIB :=" \
          -e "/^LOG4CPLUS_INCL_DIR := /c\LOG4CPLUS_INCL_DIR :=" \
          -e "/^LOG4CPLUS_LIB_DIR := /c\LOG4CPLUS_LIB_DIR :=" \
          -e "/^LOG4CPLUS_LIB := /c\LOG4CPLUS_LIB :=" \
          -e "/^GLFW_INCL_DIR := /c\GLFW_INCL_DIR := /usr/include/GLFW" \
          -e "/^GLFW_LIB_DIR := /c\GLFW_LIB_DIR := /usr/lib" \
          -e "/^PYTHON_VERSION := /c\PYTHON_VERSION :=" \
          -e "/^PYTHON_INCL_DIR := /c\PYTHON_INCL_DIR :=" \
          -e "/^PYCONFIG_INCL_DIR := /c\PYCONFIG_INCL_DIR :=" \
          -e "/^PYTHON_LIB_DIR := /c\PYTHON_LIB_DIR :=" \
          -e "/^PYTHON_LIB := /c\PYTHON_LIB :=" \
          -e "/^BOOST_PYTHON_LIB_DIR := /c\BOOST_PYTHON_LIB_DIR :=" \
          -e "/^BOOST_PYTHON_LIB := /c\BOOST_PYTHON_LIB :=" \
          -e "/^NUMPY_INCL_DIR := /c\NUMPY_INCL_DIR :=" \
          -e "/^EPYDOC := /c\EPYDOC :=" \
          -e "/^DOXYGEN := /c\DOXYGEN :=" \
          Makefile

  # Fixe erreur compilation avec gcc
  sed -i  -e "s/-isystem/-I/g" Makefile
  
  # Supprime OPTIMIZE := -O3
  sed -i  -e "s/-O3 //g" Makefile
  
  # Fixe namcap : W: ELF file ('usr/bin/*') lacks FULL RELRO, check LDFLAGS.
  sed -i  -e "s/-ldl -lm -lz/\$(LDFLAGS) -ldl -lm -lz/g" Makefile
}
  
build() {
  cd "${_name_release}/openvdb"
  # build the library and commands
  make all
}

package() {
  cd "${_name_release}/openvdb"
  # copy generated files into the directory tree rooted at $(DESTDIR)
  make install
  
  # Fix namcap : E: Insecure RPATH
  find "$pkgdir/usr/bin" -name 'vdb_*' -exec chrpath -d {} +

  # SUPPRIME doc
  rm -rf "$pkgdir"/usr/share
}
