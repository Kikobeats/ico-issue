This repository is to reproduce a strange behavior related to sharp and binaries associated.

The `index.js` has the necessary code to see the issue. For reproducing it, clone the repository and do:

```
npm run build && npm start
```

The code is using 3 software components:

```
splashy > node-vibrant > sharp
```

[splashy](https://github.com/microlinkhq/splashy/blob/master/src/index.js) is essentialy some code commodity on top of node-vibrant.

[node-vibrant](https://github.com/microlinkhq/splashy/blob/b9a6d9828578cc46383a33aaeab7e951a61d1bee/src/vibrant.js) is used as adapter layer to call sharp.

and [sharp] is the root of problems!

Looks like sharp binary is missing in some way (maybe the sub dependency binary is not missing, but the behavior is different) causing the code doesn't work properly with `ico` files.

This is a [SUCCESS](reports/success-local.txt) code report after running the repo on my local machine. However, it [FAILED](reports/failed-docker.txt) If I run using docker image.