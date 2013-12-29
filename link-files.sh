#!/bin/sh

# This script create symlinks of all files in one directory in another directory, creating
# backups of the existing files of the same name in the target directory. Can be used
# e. g. for linking all executables from a certain Cellar (Homebrew) keg into /usr/bin
# without having the original ones replaced and lost forever.
#
# USAGE: link-files.sh SOURCE_DIR TARGET_DIR [BACKUP_DIR_NAME]

# Converts a relative path to an absolute one using pwd. If an absolute path is given, it
# is left untouched.
expand_path() {
	FIRST_CHAR=`echo ${1} | cut -c1`
	if [ "$FIRST_CHAR" = "/" ]
	then
		echo "${1}"
		return 0
	else
		PWD=`pwd -P`
		echo "${PWD}/${1}"
		return 0
	fi
}

# Expand all the paths to absolute ones.
if [ -n "$1" ]
then
	SOURCE_DIR=`expand_path "$1"`
else
	echo "Source dir not given."
	exit 1
fi

if [ -n "$2" ]
then
	TARGET_DIR=`expand_path "$2"`
else
	echo "Target dir not given."
	exit 1
fi

# Determine the backup folder name. Either the third argument, or default “_backup” if not
# given.

if [ -n "$3" ]
then
	BACKUP_DIR="$3"
else
	BACKUP_DIR="_backup"
fi
BACKUP_DIR="${TARGET_DIR}/${BACKUP_DIR}"

# The backup directory will be created in the target folder. If such directory already
# exists, it will be used. If the directory cannot be created, either because of that
# there is a non-directory file with the same name, or just because mkdir fails, the
# script will exit.

if [ -e "$BACKUP_DIR" ]
then
	if [ ! -d "$BACKUP_DIR" ]
	then
		echo "Cannot use backup directory $BACKUP_DIR: File exists, but is not a directory."
		exit
	fi
	else
		mkdir "$BACKUP_DIR"
		if [ $? -ne 0 ]
		then
			echo "Cannot create backup directory $BACKUP_DIR."
		exit
	fi
fi

# For each of the files in the source directory, do the following:
# 1. If there is a file with the same name in the target directory, move it into the
#    backup directory.
# 2. Create symlink of the source file in the target directory. It will be on the place
#    of the original file, which is now moved to the backup directory.
# 3. If moving of creating of the symlink fails, the process will be aborted.

for SOURCE_ENTRY in "${SOURCE_DIR}/"*
do
	BASENAME=`basename "$SOURCE_ENTRY"`
	SOURCE_PATH="${SOURCE_DIR}/${BASENAME}"
	TARGET_PATH="${TARGET_DIR}/${BASENAME}"

	# Directories are ignored on both sides.
	if [ ! -d "$SOURCE_PATH" ]
	then
		# -e is false if the file is a link to a non-existant file.
		if [ -e "$TARGET_PATH" ] || [ -L "$TARGET_PATH" ]
		then
			if [ -d "$TARGET_PATH" ]
			then
				echo "Would not move ${TARGET_PATH}, it is a directory."
				exit
			else
				BACKUP_TARGET_PATH="${BACKUP_DIR}/${BASENAME}"
				if [ -e "$BACKUP_TARGET_PATH" ] || [ -h "$BACKUP_TARGET_PATH" ]
				then
					echo "The backup ${BACKUP_TARGET_PATH} already exists."
					exit
				fi
				
				# Now, the moving begins.
				mv "$TARGET_PATH" "$BACKUP_TARGET_PATH"
				if [ $? -ne 0 ]
				then
					echo "Cannot move ${TARGET_PATH} to ${BACKUP_TARGET_PATH}."
					exit
				fi
			fi
		fi

		# Now, the linking begins.
		ln -s "$SOURCE_PATH" "$TARGET_PATH"
		if [ $? -ne 0 ]
		then
			echo "Cannot create symlink of ${SOURCE_ENTRY} in ${TARGET_PATH}."
			exit
		fi
	fi
done
