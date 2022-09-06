FROM ico-issue-base

COPY package.json .
RUN npm install --package-lock=false --omit=dev
COPY index.js index.js

CMD [ "node", "index.js" ]
