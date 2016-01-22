#/bin/bash
IMAGE_NAME=herokuish:expa
S3_BUCKET_NAME=expa-dokku
USER_DEST_PREFIX="$1"
DESTINATION_PREFIX=${USER_DEST_PREFIX:="expa"}

fatal() {
    REASON=$1
    case "$REASON" in
        awsrc)
            echo "no AWS_ACCESS_KEY_ID found in env. please source your awsrc. exiting!"
        ;;
        image)
            echo "$IMAGE_NAME image not found in docker. exiting!"
        ;;
        *)
            echo "unknown error. exiting!"
        ;;
    esac
    exit 1
}


read -s -n 1 -p "Are you sure you want to upload a new herokuish image? [yn] " confirm
echo ""
[[ "$confirm" = "y" ]] || exit 0

!(env | grep -q AWS_ACCESS_KEY_ID) && fatal awsrc
!(docker inspect $IMAGE_NAME &> /dev/null) && fatal image

[[ -f /tmp/tgz ]] && rm /tmp/tgz
ID=$(docker run -d $IMAGE_NAME /bin/sh)
SHORTID=${ID:0:10}
DESTINATION_FILENAME=${DESTINATION_PREFIX}_herokuish_${SHORTID}.tgz

if [[ -e './stack/.scipy' ]];then
  DESTINATION_FILENAME=${DESTINATION_PREFIX}_scipy_herokuish_${SHORTID}.tgz
fi

DESTINATION=s3://$S3_BUCKET_NAME/${DESTINATION_FILENAME}

echo "exporting $ID"
docker export $ID | gzip -9c > /tmp/tgz || exit 1

echo "uploading to $DESTINATION"
aws s3 cp /tmp/tgz $DESTINATION --acl public-read
