##@ Commands

.PHONY: heroku/config/set
heroku/config/set: ilcampaigncash/.env ## Copy ilcampaigncash/.env to Heroku variables
	heroku config:set $(shell grep "^[^#;]" $< | tr '\n' ' ')

.PHONY: help
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z\%\\.\/_-]+:.*?##/ { printf "\033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)