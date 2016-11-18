FROM u2668/r-with-packages

COPY . /usr/local/src/bot-brain
WORKDIR /usr/local/src/bot-brain
CMD ["Rscript", "run-rest-api.R"]
