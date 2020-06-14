set -e

clear

cd pure
spago --quiet bundle-module --main Pure --to dist/apickli.js
cd ..

node index.js
