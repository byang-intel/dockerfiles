#!/bin/bash -e

: ${MYUNAME:=$USER}
: ${MYUID:=`id -u $MYUNAME`}
: ${MYPROJECTNAME:=eng_build}
# this defines what we are building against, it's the main thing that changes between Versions
#    R4 - tis-r4-newton
#    R5 - tis-r5-pike
: ${MY_TC_RELEASE:=tis-r5-pike}

mkdir -p /localdisk/designer/$MYUNAME/$MYPROJECTNAME
chown $MYUID:cgts /localdisk/designer/$MYUNAME/$MYPROJECTNAME

mkdir -p /localdisk/loadbuild/$MYUNAME/$MYPROJECTNAME
chown $MYUID:cgts /localdisk/loadbuild/$MYUNAME/$MYPROJECTNAME

echo > /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export http_proxy=10.239.4.80:913" >> /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export https_proxy=10.239.4.80:913" >> /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export no_proxy=localhost,127.0.0.1,*.intel.com" >> /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export USER=$MYUNAME" >> /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export PROJECT=$MYPROJECTNAME" >> /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export SRC_BUILD_ENVIRONMENT=$MY_TC_RELEASE" >> /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export MY_BUILD_ENVIRONMENT=\$USER-\$PROJECT-\$SRC_BUILD_ENVIRONMENT" >> /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export MY_BUILD_ENVIRONMENT_FILE=\${MY_BUILD_ENVIRONMENT}.cfg" >> /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export MY_BUILD_ENVIRONMENT_FILE_STD=\${MY_BUILD_ENVIRONMENT}-std.cfg" >> /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export MY_BUILD_ENVIRONMENT_FILE_RT=\${MY_BUILD_ENVIRONMENT}-rt.cfg" >> /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export MY_BUILD_DIR=/localdisk/loadbuild/\$USER/\$PROJECT" >> /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export MY_WORKSPACE=\$MY_BUILD_DIR" >> /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export MY_LOCAL_DISK=/localdisk/designer/\$USER" >> /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export MY_REPO_ROOT_DIR=\$MY_LOCAL_DISK/\$PROJECT" >> /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export MY_REPO=\$MY_REPO_ROOT_DIR/cgcs-root" >> /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export MY_SRC_RPM_BUILD_DIR=\$MY_BUILD_DIR/rpmbuild" >> /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export MY_BUILD_CFG=\$MY_WORKSPACE/\$MY_BUILD_ENVIRONMENT_FILE" >> /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export MY_BUILD_CFG_STD=\$MY_WORKSPACE/std/\$MY_BUILD_ENVIRONMENT_FILE_STD" >> /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export MY_BUILD_CFG_RT=\$MY_WORKSPACE/rt/\$MY_BUILD_ENVIRONMENT_FILE_RT" >> /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export MY_DEBUG_BUILD_CFG_STD=\$MY_WORKSPACE/std/configs/\${MY_BUILD_ENVIRONMENT}-std/\${MY_BUILD_ENVIRONMENT}-std.b0.cfg" >> /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export MY_DEBUG_BUILD_CFG_STD=\$MY_WORKSPACE/std/configs/\${MY_BUILD_ENVIRONMENT}-std/\${MY_BUILD_ENVIRONMENT}-rt.b0.cfg" >> /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export MY_MOCK_ROOT=\$MY_WORKSPACE/mock/root" >> /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export FORMAL_BUILD=0" >> /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export PATH=\$MY_REPO/build-tools:\$PATH" >> /localdisk/config/prj-$MYPROJECTNAME.conf
echo "export PATH=/usr/local/bin:/localdisk/designer/\$MYUNAME/bin:\$PATH" >> /localdisk/config/prj-$MYPROJECTNAME.conf
cat >> /localdisk/config/prj-$MYPROJECTNAME.conf <<__EOF__
export PS1='\[\e[38;5;39m\]\u\[\e[0m\]@$MYPROJECTNAME@\[\e[38;5;208m\]\H \[\e[38;5;39m\]\w \[\e[38;5;39m\]$ \[\e[0;0m\]'
__EOF__

source /localdisk/config/prj-$MYPROJECTNAME.conf
/bin/bash
