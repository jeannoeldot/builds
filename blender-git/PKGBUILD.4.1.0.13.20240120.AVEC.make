# Maintainer: Name <name@fai.com>

pkgname=blender-git
pkgver=4.1.0.13.20240120
pkgrel=1
pkgdesc="A fully integrated 3D graphics creation suite"
arch=('x86_64')
license=('GPL')
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
          'llvm15-libs' 'clang15'
          'potrace' 'pugixml' 'libharu' 'libepoxy'
          'libdecor' 'wayland-protocols' 'libxkbcommon'
          'fribidi' 'harfbuzz' 'minizip-ng' 'pybind11' 'shaderc'
          'vulkan-headers' 'vulkan-icd-loader' 'vulkan-driver'
          'opencolorio' 'libdeflate'
          'opencollada-git' 'openimageio-git'
          'openshadinglanguage-git'
          'opensubdiv-git' 'openvdb-git' 'alembic-git'
          'embree-git' 'openimagedenoise-git'
          'openpgl-git'
          'zstd'
)
makedepends=('cmake' 'boost' 'mesa' 'llvm15'
             'cuda'
             'git'
             'mold'
)
optdepends=('cuda: cycles renderer cuda support')
conflicts=('blender')
provides=('blender')
#options=('!strip')
source=("$pkgname-$pkgver.tar.gz"
        "LibAssetsPublish-$pkgver.zip"
        "OptiX-7.7-Include.zip"
)
sha256sums=('fd413ee40e1649852729a68df94da17d371acbc2056426df372627bf747974f3'
            '33f76106997afb330772aa72036006bdfdcb6143499101195bff914573f9ba32'
            'b11eb06327d7f20dcfac413af720411112adb086b06b4f035c4994df0e5f99ab'
)

_gitname="blender"

prepare() {
  cd "${_gitname}"

  ## Cycles: Workaround for performance loss with the CUDA 9.0 SDK.
  ## Commit 1febc858559c054603073301a6c6dae44c737830 du 21/11/2017. Stefan Werner
  #sed -i -e "s|define CUDA_KERNEL_MAX_REGISTERS 48|define CUDA_KERNEL_MAX_REGISTERS 64|" intern/cycles/kernel/kernels/cuda/kernel_config.h

  # Buildinfo : Workaround for HASH, BRANCH et COMMIT_TIMESTAMP
  sed -i -e 's|MY_WC_HASH "unknown"|MY_WC_HASH "af5731ce03a2"|' build_files/cmake/buildinfo.cmake
  sed -i -e 's|MY_WC_BRANCH "unknown"|MY_WC_BRANCH "main"|' build_files/cmake/buildinfo.cmake
  sed -i -e 's|MY_WC_COMMIT_TIMESTAMP 0|MY_WC_COMMIT_TIMESTAMP 1705774656|' build_files/cmake/buildinfo.cmake
}

build() {
  cd "${_gitname}"
  
  local PYTHON_VER=3.11

  # Who even knows why this is needed
  export CFLAGS="$CFLAGS -lSPIRV -lSPIRV-Tools -lSPIRV-Tools-opt -lSPIRV-Tools-link -lSPIRV-Tools-reduce -lSPIRV-Tools-shared -lglslang"
  export CXXFLAGS="$CXXFLAGS -lSPIRV -lSPIRV-Tools -lSPIRV-Tools-opt -lSPIRV-Tools-link -lSPIRV-Tools-reduce -lSPIRV-Tools-shared -lglslang"

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
        -DWITH_USD=OFF \
        -DWITH_MATERIALX=OFF \
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
        -DLLVM_VERSION=15 \
        -DWITH_LLVM=ON \
        -DWITH_CLANG=ON \
        -DCLANG_INCLUDE_DIR=/usr/lib/llvm15/include/clang \
        -DCLANG_LIBRARIES=/usr/lib/llvm15/lib \
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
