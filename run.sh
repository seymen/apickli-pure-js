set -e

clear

cd pure
spago --quiet bundle-module --main Apickli --to dist/apickli.js
cd ..

node index.js
