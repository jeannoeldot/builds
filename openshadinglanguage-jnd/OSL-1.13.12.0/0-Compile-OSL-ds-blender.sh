
OSL_SOURCE=( "https://github.com/mont29/OpenShadingLanguage.git" )
OSL_REPO_UID="85179714e1bc69cd25ecb6bb711c1a156685d395"


# OSL needs to be compiled for now!
OSL_VERSION="1.5.0"
OSL_VERSION_MIN=$OSL_VERSION
OSL_FORCE_REBUILD=false
OSL_SKIP=false


#### Build OSL ####
_init_osl() {
  _src=$SRC/OpenShadingLanguage-$OSL_VERSION
  _git=true
  _inst=$INST/osl-$OSL_VERSION
  _inst_shortcut=$INST/osl
}

clean_OSL() {
  _init_osl
  _clean
}

compile_OSL() {
  # To be changed each time we make edits that would modify the compiled result!
  osl_magic=15
  _init_osl

  # Clean install if needed!
  magic_compile_check osl-$OSL_VERSION $osl_magic
  if [ $? -eq 1 -o $OSL_FORCE_REBUILD == true ]; then
    clean_OSL
  fi

  if [ ! -d $_inst ]; then
    INFO "Building OpenShadingLanguage-$OSL_VERSION"

    prepare_opt

    if [ ! -d $_src ]; then
      mkdir -p $SRC

      #download OSL_SOURCE[@] "$_src.tar.gz"

      #INFO "Unpacking OpenShadingLanguage-$OSL_VERSION"
      #tar -C $SRC --transform "s,(.*/?)OpenShadingLanguage-[^/]*(.*),\1OpenShadingLanguage-$OSL_VERSION\2,x" \
          #-xf $_src.tar.gz

      git clone ${OSL_SOURCE[0]} $_src

    fi

    cd $_src

    git remote set-url origin $OSL_SOURCE

    # XXX For now, always update from latest repo...
    git pull -X theirs origin master

    # Stick to same rev as windows' libs...
    git checkout $OSL_REPO_UID
    git reset --hard

    # Always refresh the whole build!
    if [ -d build ]; then
      rm -rf build
    fi    
    mkdir build
    cd build

    cmake_d="-D CMAKE_BUILD_TYPE=Release"
    cmake_d="$cmake_d -D CMAKE_INSTALL_PREFIX=$_inst"
    cmake_d="$cmake_d -D BUILD_TESTING=OFF"
    cmake_d="$cmake_d -D STOP_ON_WARNING=OFF"
    cmake_d="$cmake_d -D BUILDSTATIC=OFF"

    cmake_d="$cmake_d -D ILMBASE_VERSION=$ILMBASE_VERSION"

    if [ $_with_built_openexr == true ]; then
      INFO "ILMBASE_HOME=$INST/openexr"
      cmake_d="$cmake_d -D ILMBASE_HOME=$INST/openexr"
    fi

    if [ -d $INST/boost ]; then
      cmake_d="$cmake_d -D BOOST_ROOT=$INST/boost -D Boost_NO_SYSTEM_PATHS=ON"
    fi

    if [ -d $INST/oiio ]; then
      cmake_d="$cmake_d -D OPENIMAGEIOHOME=$INST/oiio"
    fi

    if [ ! -z $LLVM_VERSION_FOUND ]; then
      cmake_d="$cmake_d -D LLVM_VERSION=$LLVM_VERSION_FOUND"
      if [ -d $INST/llvm ]; then
        cmake_d="$cmake_d -D LLVM_DIRECTORY=$INST/llvm"
        cmake_d="$cmake_d -D LLVM_STATIC=ON"
      fi
    fi

    cmake $cmake_d ..

    make -j$THREADS && make install
    make clean

    if [ -d $_inst ]; then
      _create_inst_shortcut
    else
      ERROR "OpenShadingLanguage-$OSL_VERSION failed to compile, exiting"
      exit 1
    fi

    magic_compile_set osl-$OSL_VERSION $osl_magic

    cd $CWD
    INFO "Done compiling OpenShadingLanguage-$OSL_VERSION!"
  else
    INFO "Own OpenShadingLanguage-$OSL_VERSION is up to date, nothing to do!"
    INFO "If you want to force rebuild of this lib, use the --force-osl option."
  fi

  run_ldconfig "osl"
}

