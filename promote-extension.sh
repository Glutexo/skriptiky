#!/bin/sh

# Renames all files whose filename ends with an extension that is not
# preceded by a period: The period is inserted between the filename 
# and its extension. E. g. promote-extension.sh html renames a file
# named examplehtml to example.html. The script operates on files in
# the current directory.

EXTENSION=$1
if [ -z "$EXTENSION" ]
then
	echo "Usage: promote-extension.sh EXTENSION"
	exit 1
fi

# Get all files that end with an extension not preceded by a period.
FILES=`ls | grep [^\\.]${EXTENSION}`
for FILE in $FILES
do
	RENAMED=`echo "$FILE" | sed s/${EXTENSION}\$//`
	mv "$FILE" "${RENAMED}.${EXTENSION}"
done
