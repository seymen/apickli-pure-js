set -e

clear

cd pure
spago --quiet bundle-module --main Pure --to dist/pure.js
cd ..

node index.js
