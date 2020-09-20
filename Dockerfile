FROM jekyll/jekyll:4.0

RUN gems install site-map

CMD ["jekyll", "serve"]
