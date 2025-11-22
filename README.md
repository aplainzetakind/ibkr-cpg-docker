# ibkr-cpg-docker

This repository contains a barebones dockerization of the Interactive Brokers
Client Portal Gateway. The container starts CPG, then logs in with a paper
account using the credentials passed with `IBKR_PAPER_USERNAME` and
`IBKR_PAPER_PASSWORD` variables, *or*, if the variable `IBKR_LIVE` is set to
`LIVE`, uses `IBKR_LIVE_USERNAME` and `IBKR_LIVE_PASSWORD` to log in to the
live account. The container repeats the login every 12 hours (at noon and
midnight UTC) and checks status every 2 minutes while running.
