
### build the builder first
cd base-images/ || exit
echo "<<<<<<<<<< ANTITHESIS >>>>>>>>>> - Building base images."
docker build --registries-conf=`pwd`/../../../registries.conf --no-cache -t etb-client-builder -f etb-client-builder.Dockerfile .
docker build --registries-conf=`pwd`/../../../registries.conf --no-cache -t etb-client-runner -f etb-client-runner.Dockerfile .

### els then cls
cd ../el/ || exit
echo "<<<<<<<<<< ANTITHESIS >>>>>>>>>> - Building execution clients"
./rebuild_dockers.sh

cd ../cl/ || exit
# cd cl/ || exit
echo "<<<<<<<<<< ANTITHESIS >>>>>>>>>> - Building consensus clients"
./rebuild_dockers.sh


cd ../fuzzers/ || exit
# cd fuzzers/ || exit
echo "<<<<<<<<<< ANTITHESIS >>>>>>>>>> - building fuzzers."
./rebuild_dockers.sh
#
cd ../base-images/ || exit
# cd base-images/ || exit
echo "<<<<<<<<<< ANTITHESIS >>>>>>>>>> - Merging all clients."
# currently mainnet configs have not been modified to support the new boostrapper
docker build --registries-conf=`pwd`/../../../registries.conf --no-cache -t etb-all-clients:minimal -f etb-all-clients_minimal.Dockerfile .
docker build --registries-conf=`pwd`/../../../registries.conf --no-cache -t etb-all-clients:minimal-fuzz -f etb-all-clients_minimal-fuzz.Dockerfile .