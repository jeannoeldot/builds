# Maintainer: Name <name@fai.com>

pkgname=blender-git
pkgver=4.2.0.5.20240220
pkgrel=1
pkgdesc="A fully integrated 3D graphics creation suite"
arch=('x86_64')
license=('GPL-3.0-or-later')
url="https://blender.org/"
depends=('desktop-file-utils' 'hicolor-icon-theme' 'shared-mime-info'
          'libjpeg' 'libpng' 'openjpeg2' 'libtiff' 'openexr' 'libwebp'
          'python'
          'ffmpeg' 'fftw'
          'openal' 'freetype2' 'libsndfile' 'jack2' 'pipewire-pulse'
          'sdl2'
          'libgl' 'glfw-x11'
          'libxi' 'libxmu' 'libxxf86vm' 'libxfixes' 'libxrender'
          'boost-libs' 'onetbb'
          'jemalloc'
          'python-numpy' 'python-psutil' 'python-requests' 'python-zstandard' 'pystring'
          'fmt'
          'llvm-libs' 'clang'
          'potrace' 'pugixml' 'libharu' 'libepoxy'
          'libdecor' 'wayland-protocols' 'libxkbcommon'
          'fribidi' 'harfbuzz' 'minizip-ng' 'pybind11' 'shaderc'
          'vulkan-headers' 'vulkan-icd-loader' 'vulkan-driver'
          'opencolorio' 'libdeflate'
          'opencollada-git' 'openimageio-git'
          'openshadinglanguage-git'
          'opensubdiv-git' 'openvdb-git' 'alembic-git'
          'embree-git' 'openimagedenoise-git'
          'openpgl-git' 'materialx' 'openusd-git'
          'zstd'
)
makedepends=('cmake' 'boost' 'mesa' 'llvm'
             'cuda'
             'git'
             'mold'
)
optdepends=('cuda: cycles renderer cuda support')
conflicts=('blender')
provides=('blender')
#options=('!strip')
options=('!debug')
source=("$pkgname-$pkgver.tar.gz"
        "LibAssetsPublish-$pkgver.zip"
        "OptiX-7.7-Include.zip"
)
sha256sums=('95421a9f9147284131ac6c9b3939dec454ce9f8f163f783b9fafa7515b4f039c'
            '0f86b420db5557c6d97d54f46ae719c6a887241b66ecd50dd718a2d62e9994b4'
            'b11eb06327d7f20dcfac413af720411112adb086b06b4f035c4994df0e5f99ab'
)

_gitname="blender"

prepare() {
  cd "${_gitname}"

  ## Cycles: Workaround for performance loss with the CUDA 9.0 SDK.
  ## Commit 1febc858559c054603073301a6c6dae44c737830 du 21/11/2017. Stefan Werner
  #sed -i -e "s|define CUDA_KERNEL_MAX_REGISTERS 48|define CUDA_KERNEL_MAX_REGISTERS 64|" intern/cycles/kernel/kernels/cuda/kernel_config.h

  # Buildinfo : Workaround for HASH, BRANCH et COMMIT_TIMESTAMP
  sed -i -e 's|MY_WC_HASH "unknown"|MY_WC_HASH "148cad93e364"|' build_files/cmake/buildinfo.cmake
  sed -i -e 's|MY_WC_BRANCH "unknown"|MY_WC_BRANCH "main"|' build_files/cmake/buildinfo.cmake
  sed -i -e 's|MY_WC_COMMIT_TIMESTAMP 0|MY_WC_COMMIT_TIMESTAMP 1708431496|' build_files/cmake/buildinfo.cmake
}

build() {
  cd "${_gitname}"
  
  local PYTHON_VER=3.11

  cmake \
        -Bbuild \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_FLAGS_RELEASE:STRING=-DNDEBUG \
        -DCMAKE_CXX_FLAGS_RELEASE:STRING=-DNDEBUG \
        -DCMAKE_SKIP_RPATH=ON \
        -DASSET_BUNDLE_DIR="${srcdir}"/lib/assets/publish \
        -DOPTIX_ROOT_DIR="${srcdir}" \
        -DWITH_XR_OPENXR=OFF \
        -DWITH_SYSTEM_FREETYPE=ON \
        -DWITH_HYDRA=OFF \
        -DWITH_LIBS_PRECOMPILED=OFF \
        -DWITH_INPUT_NDOF=OFF \
        -DWITH_INSTALL_PORTABLE=OFF \
        -DWITH_PYTHON_INSTALL=OFF \
        -DWITH_PYTHON_INSTALL_NUMPY=OFF \
        -DWITH_PYTHON_INSTALL_REQUESTS=OFF \
        -DWITH_PYTHON_INSTALL_ZSTANDARD=OFF \
        -DCUDA_HOST_COMPILER=/usr/bin/gcc-12 \
        -DWITH_CYCLES_CUDA_BINARIES=ON \
        -DCYCLES_CUDA_BINARIES_ARCH="sm_86;compute_86" \
        -DWITH_CYCLES_NATIVE_ONLY=ON \
        -DWITH_CYCLES_DEVICE_HIP=OFF \
        -DWITH_CYCLES_DEVICE_METAL=OFF \
        -DLLVM_VERSION=16 \
        -DWITH_LLVM=ON \
        -DWITH_CLANG=ON \
        -DCLANG_INCLUDE_DIR=/usr/include/clang \
        -D_CLANG_LIBRARIES=/usr/lib \
        -DWITH_LINKER_GOLD=OFF \
        -DWITH_LINKER_MOLD=ON \
        -DPYTHON_VERSION=${PYTHON_VER} \
        -DPYTHON_LIBPATH=/usr/lib \
        -DPYTHON_LIBRARY=python${PYTHON_VER} \
        -DPYTHON_INCLUDE_DIRS=/usr/include/python${PYTHON_VER}
  make -C build
}

package() {
  # Blender
  cd "${_gitname}"
  DESTDIR="${pkgdir}" make -C build install

  # voir Community
  python -m compileall -d /usr/share/blender "${pkgdir}/usr/share/blender"
  python -O -m compileall -d /usr/share/blender "${pkgdir}/usr/share/blender"
}
