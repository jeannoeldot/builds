
blender/build_files/build_environment/install_deps.sh

    --force-osd
        Force the rebuild of OpenSubdiv.

    --skip-osd
        Unconditionally skip OpenSubdiv installation/building.

# OpenSubdiv needs to be compiled for now
OSD_VERSION="3.0.2"
OSD_VERSION_MIN=$OSD_VERSION
OSD_FORCE_REBUILD=false
OSD_SKIP=false

  --ver-osd)
      OSD_VERSION="$2"
      OSD_VERSION_MIN=$OSD_VERSION
      shift; shift; continue


    --force-osd)
      OSD_FORCE_REBUILD=true; shift; continue
    ;;
    
    --skip-osd)
      OSD_SKIP=true; shift; continue
    ;;    

OSD_USE_REPO=true
# Script foo to make the version string compliant with the archive name: 
# ${Varname//SearchForThisChar/ReplaceWithThisChar}
OSD_SOURCE=( "https://github.com/PixarAnimationStudios/OpenSubdiv/archive/v${OSD_VERSION//./_}.tar.gz" )
OSD_SOURCE_REPO=( "https://github.com/PixarAnimationStudios/OpenSubdiv.git" )
OSD_SOURCE_REPO_UID="404659fffa659da075d1c9416e4fc939139a84ee"
OSD_SOURCE_REPO_BRANCH="dev"

#### Build OSD ####
_init_osd() {
  _src=$SRC/OpenSubdiv-$OSD_VERSION
  _git=true
  _inst=$INST/osd-$OSD_VERSION
  _inst_shortcut=$INST/osd
}

clean_OSD() {
  _init_osd
  _clean
}

compile_OSD() {
  # To be changed each time we make edits that would modify the compiled result!
  osd_magic=0
  _init_osd

  # Clean install if needed!
  magic_compile_check osd-$OSD_VERSION $osd_magic
  if [ $? -eq 1 -o $OSD_FORCE_REBUILD == true ]; then
    clean_OSD
  fi

  if [ ! -d $_inst ]; then
    INFO "Building OpenSubdiv-$OSD_VERSION"

    prepare_opt

    if [ ! -d $_src ]; then
      mkdir -p $SRC

      if [ $OSD_USE_REPO == true ]; then
        git clone ${OSD_SOURCE_REPO[0]} $_src
      else
        download OSD_SOURCE[@] "$_src.tar.gz"
        INFO "Unpacking OpenSubdiv-$OSD_VERSION"
        tar -C $SRC --transform "s,(.*/?)OpenSubdiv-[^/]*(.*),\1OpenSubdiv-$OSD_VERSION\2,x" \
            -xf $_src.tar.gz
      fi
    fi

    cd $_src

    if [ $OSD_USE_REPO == true ]; then
      git remote set-url origin ${OSD_SOURCE_REPO[0]}
      # XXX For now, always update from latest repo...
      git pull --no-edit -X theirs origin $OSD_SOURCE_REPO_BRANCH
      # Stick to same rev as windows' libs...
      git checkout $OSD_SOURCE_REPO_UID
      git reset --hard
    fi

    # Always refresh the whole build!
    if [ -d build ]; then
      rm -rf build
    fi    
    mkdir build
    cd build

    cmake_d="-D CMAKE_BUILD_TYPE=Release"
    cmake_d="$cmake_d -D CMAKE_INSTALL_PREFIX=$_inst"
    # ptex is only needed when nicholas bishop is ready
    cmake_d="$cmake_d -D NO_PTEX=1"
    cmake_d="$cmake_d -D NO_CLEW=1"
    # maya plugin, docs, tutorials, regression tests and examples are not needed
    cmake_d="$cmake_d -D NO_MAYA=1 -D NO_DOC=1 -D NO_TUTORIALS=1 -D NO_REGRESSION=1 -DNO_EXAMPLES=1"

    cmake $cmake_d ..

    make -j$THREADS && make install
    make clean

    if [ -d $_inst ]; then
      _create_inst_shortcut
    else
      ERROR "OpenSubdiv-$OSD_VERSION failed to compile, exiting"
      exit 1
    fi

    magic_compile_set osd-$OSD_VERSION $osd_magic

    cd $CWD
    INFO "Done compiling OpenSubdiv-$OSD_VERSION!"
  else
    INFO "Own OpenSubdiv-$OSD_VERSION is up to date, nothing to do!"
    INFO "If you want to force rebuild of this lib, use the --force-osd option."
  fi

  run_ldconfig "osd"
}

