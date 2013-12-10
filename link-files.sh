#!/bin/sh

# This script create symlinks of all files in
# one directory in another directory, creating
# backups of the existing files of the same
# name in the target directory.
# Can be used e. g. for linking all executables
# from a certain Cellar (Homebrew) keg into
# /usr/bin without getting rid of the original
# ones being replaced.
#
# USAGE: link-files.sh SOURCE_DIR TARGET_DIR [BACKUP_DIR_NAME]

# First, determine the backup folder name.
# Either the third argument, or default
# “_backup” if not given.

if [ $3 ]
then
  BACKUP_DIR=$3
else
  BACKUP_DIR=_backup
fi

BACKUP_PATH=$2/$BACKUP_DIR

# The backup directory will be created in the
# target folder. If such directory already
# exists, it will be used. If the directory
# cannot be created, either because of that
# there is a non-directory file with the same
# name, or just because mkdir fails, this
# script will exit.

if [ -e $BACKUP_PATH ]
then
  if [ ! -d $BACKUP_PATH ]
  then
    echo "Cannot use backup path $BACKUP_PATH: File exists, but is not a directory."
    exit
  fi
else
  mkdir $BACKUP_PATH
  if [ $? -ne 0 ]
  then
    echo "Cannot create backup directory $BACKUP_PATH."
    exit
  fi
fi

# For each of the files in the source
# directory, do the following:
# 1. If there is a file with the same name in
#    the target directory, move it into the
#    backup directory.
# 2. Create symlink of the source file in the
#    target directory. It will be on the place
#    of the original file, which is now moved
#    to the backup directory.
# 3. If moving of creating of the symlink
#    fails, the process will be aborted.

PWD=`pwd -P`
for SOURCE_ENTRY in $1/*
do
  BASENAME=`basename $SOURCE_ENTRY`
  TARGET_PATH=$2/$BASENAME

  # Directories are ignored on both sides.
  if [ ! -d $SOURCE_ENTRY ]
  then
    if [ -e $TARGET_PATH ] || [ -h $TARGET_PATH ]
    then
      if [ -d $TARGET_PATH ]
      then
        echo "Would not move $TARGET_PATH, it is a directory."
        exit
      else
	BACKUP_TARGET_PATH=$BACKUP_PATH/$BASENAME
        if [ -e $BACKUP_TARGET_PATH ] || [ -h $BACKUP_TARGET_PATH ]
        then
          echo "The backup $BACKUP_TARGET_PATH already exists."
          exit
        fi
        # Now, the moving begins.
        echo mv $TARGET_PATH $BACKUP_TARGET_PATH
        mv $TARGET_PATH $BACKUP_TARGET_PATH
        if [ $? -ne 0 ]
        then
          echo "Cannot move $TARGET_PATH to $BACKUP_TARGET_PATH."
          exit
        fi
      fi
    fi

    # Now, the linking begins.
    echo ln -s \"$PWD/$SOURCE_ENTRY\" \"$PWD/$TARGET_PATH\"
    ln -s "$PWD/$SOURCE_ENTRY" "$PWD/$TARGET_PATH"
    if [ $? -ne 0 ]
    then
      echo "Cannot create symlink of $SOURCE_ENTRY in $TARGET_PATH."
      exit
    fi
  fi
done
