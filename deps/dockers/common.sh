# Public function
# Usage:
# $1: Image tag
# $2: Dockerfile
function build_image() {
    if [ "${REBUILD_IMAGES}" == 1 ]; then
        container_builder build --no-cache -t $1 -f $2 || record_image_failure $1
    else
        container_builder build -t $1 -f $2 || record_image_failure $1 
    fi
}

function antithesis_log_step() {
    echo "<<<<<<<<<< ANTITHESIS >>>>>>>>>> — $1"
}

# Private function
function container_builder() {
    if hash docker 2>/dev/null; then
        BUILDKIT=1 docker "$@"
    else
        podman "$@"
    fi
}

# Private function
function record_image_failure() {
	echo $1 >> $FAILED_IMAGES_LOG
}